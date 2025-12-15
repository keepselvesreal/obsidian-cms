#!/bin/bash

set -euo pipefail

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/extract-images.sh"
source "$SCRIPT_DIR/lib/copy-images.sh"
source "$SCRIPT_DIR/lib/update-paths.sh"
source "$SCRIPT_DIR/lib/validate-links.sh"

# 설정 변수
OBSIDIAN_VAULT="/home/nadle/문서/google-drive-obsidian"
PUBLIC_DIR="$OBSIDIAN_VAULT/public"
CONTENT_DIR="$PROJECT_ROOT/content"
DRY_RUN=false
VALIDATE_ONLY=false

# 옵션 처리
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --validate-only)
      VALIDATE_ONLY=true
      shift
      ;;
    --verbose)
      set -x
      shift
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done

# 헬프 출력
print_help() {
  cat << 'EOF'
Usage: ./sync-content.sh [OPTIONS]

Options:
  --dry-run           Run without making changes (preview mode)
  --validate-only     Only validate links, don't sync
  --verbose           Show all bash commands
  --help              Show this help message

Examples:
  ./sync-content.sh                    # Normal sync
  ./sync-content.sh --dry-run          # Preview changes
  ./sync-content.sh --validate-only    # Check links only
  ./sync-content.sh --verbose          # Debug mode

Logs:
  Latest log: logs/sync-latest.log
  Dated logs: logs/25-12-15-1100.log
EOF
}

# 메인 함수
main() {
  log_section "Sync Started"
  log_info "Working directory: $PROJECT_ROOT"
  log_info "Obsidian vault: $OBSIDIAN_VAULT"
  log_info "Public folder: $PUBLIC_DIR"
  log_info "Content folder: $CONTENT_DIR"
  log_info "Log file: $LOG_FILE"

  if [ "$DRY_RUN" = true ]; then
    log_warning "DRY-RUN MODE: No changes will be made"
  fi

  # 시작 시간
  START_TIME=$(date +%s)

  # 폴더 존재 여부 확인
  if [ ! -d "$PUBLIC_DIR" ]; then
    log_error "Public folder not found: $PUBLIC_DIR"
    exit 1
  fi

  if [ ! -d "$CONTENT_DIR" ]; then
    log_info "Creating content directory: $CONTENT_DIR"
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$CONTENT_DIR"
    fi
  fi

  # 초기화
  FILE_COUNT=0
  IMAGE_COUNT=0
  ERROR_COUNT=0
  LINK_ERRORS=0

  # Step 1: 각 .md 파일 처리
  log_section "Processing Markdown Files"

  while IFS= read -r md_file; do
    if [ -z "$md_file" ]; then
      continue
    fi

    log_info "Processing: $md_file"
    FILE_COUNT=$((FILE_COUNT + 1))

    # Step 2: 이미지 추출 및 복사 (Obsidian과 마크다운 형식 모두)
    log_section "Extracting and Copying Images"

    # Obsidian 형식 이미지 추출: ![[filename.png]]
    obsidian_images=$(grep -oP '!\[\[\K[^]]+(?=\]\])' "$md_file" 2>/dev/null || true)

    # 마크다운 형식 이미지 경로 추출: ![alt](../../../resources/attachments/...)
    markdown_images=$(grep -oP '!\[.*?\]\(\K[^)]*attachments[^)]*' "$md_file" 2>/dev/null || true)

    # Obsidian 형식 처리
    while IFS= read -r img_filename; do
      if [ -z "$img_filename" ]; then
        continue
      fi

      if [ "$DRY_RUN" = false ]; then
        if copy_image_if_missing "$img_filename" "$PUBLIC_DIR"; then
          IMAGE_COUNT=$((IMAGE_COUNT + 1))
        else
          ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
      else
        log_info "[DRY-RUN] Would copy Obsidian image: $img_filename"
        IMAGE_COUNT=$((IMAGE_COUNT + 1))
      fi
    done <<< "$obsidian_images"

    # 마크다운 형식 처리
    while IFS= read -r img_path; do
      if [ -z "$img_path" ]; then
        continue
      fi

      filename=$(basename "$img_path")
      source_img="$OBSIDIAN_VAULT/resources/attachments/$filename"
      dest_img="$PUBLIC_DIR/attachments/$filename"

      if [ "$DRY_RUN" = false ]; then
        mkdir -p "$(dirname "$dest_img")"

        if [ ! -f "$dest_img" ] && [ -f "$source_img" ]; then
          if cp "$source_img" "$dest_img"; then
            log_success "Copied markdown image: $filename"
            IMAGE_COUNT=$((IMAGE_COUNT + 1))
          else
            log_error "Failed to copy markdown image: $filename"
            ERROR_COUNT=$((ERROR_COUNT + 1))
          fi
        elif [ -f "$dest_img" ]; then
          log_info "Markdown image already exists: $filename"
        else
          log_error "Source markdown image not found: $source_img"
          ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
      else
        if [ ! -f "$dest_img" ] && [ -f "$source_img" ]; then
          log_info "[DRY-RUN] Would copy markdown image: $filename"
          IMAGE_COUNT=$((IMAGE_COUNT + 1))
        fi
      fi
    done <<< "$markdown_images"

    # Step 3: 경로 수정 (외부 경로 감지 시 작업 중지)
    log_section "Updating Image Paths"

    if [ "$DRY_RUN" = false ]; then
      if ! update_image_paths "$md_file"; then
        log_error "Sync aborted: Cannot process file with external references"
        return 1
      fi
    else
      log_info "[DRY-RUN] Would update paths: $md_file"
    fi

    # Step 4: 링크 검증
    log_section "Validating Links"

    if ! validate_links_in_file "$md_file" "$PUBLIC_DIR"; then
      LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

  done < <(find "$PUBLIC_DIR" -type f -name "*.md")

  # Step 5: content 폴더로 동기화
  if [ "$VALIDATE_ONLY" = false ]; then
    log_section "Syncing to Content Folder"

    if [ "$DRY_RUN" = false ]; then
      if rsync -av --delete "$PUBLIC_DIR/" "$CONTENT_DIR/" 2>&1 | tee -a "$LOG_FILE" "$LOG_LATEST"; then
        log_success "Synced to content folder"
      else
        log_error "Failed to sync to content folder"
        ERROR_COUNT=$((ERROR_COUNT + 1))
      fi
    else
      log_info "[DRY-RUN] Would sync: $PUBLIC_DIR/ → $CONTENT_DIR/"
    fi
  fi

  # 최종 요약
  log_section "Sync Summary"

  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))

  log_info "Total markdown files: $FILE_COUNT"
  log_info "Images copied: $IMAGE_COUNT"
  log_info "Link errors: $LINK_ERRORS"
  log_info "Total errors: $ERROR_COUNT"
  log_info "Duration: ${DURATION}s"

  if [ $ERROR_COUNT -eq 0 ]; then
    log_success "Sync completed successfully!"
    return 0
  else
    log_error "Sync completed with $ERROR_COUNT error(s)"
    return 1
  fi
}

# 스크립트 실행
main "$@"
