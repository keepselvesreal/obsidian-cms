#!/bin/bash

set -euo pipefail

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/obsidian-image-extractor.sh"
source "$SCRIPT_DIR/lib/image-copier.sh"
source "$SCRIPT_DIR/lib/image-path-converter.sh"
source "$SCRIPT_DIR/lib/file-syncer.sh"
source "$SCRIPT_DIR/lib/folder-syncer.sh"

# 설정 변수
OBSIDIAN_VAULT="/home/nadle/문서/google-drive-obsidian"
PUBLIC_DIR="$OBSIDIAN_VAULT/public"
DRY_RUN=false

# 옵션 처리
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      # 첫 번째 인자는 경로로 처리
      if [ -z "${TARGET_PATH:-}" ]; then
        TARGET_PATH="$1"
        shift
      else
        echo "Unknown option: $1"
        print_help
        exit 1
      fi
      ;;
  esac
done

# 헬프 출력
print_help() {
  cat << 'EOF'
Usage: ./to-public-sync.sh [PATH] [OPTIONS]

Arguments:
  PATH                Relative path from Obsidian vault
                      - Folder: syncs all contents recursively
                      - File: syncs only that file

Options:
  --dry-run           Run without making changes (preview mode)
  --help              Show this help message

Examples:
  # Sync entire folder recursively
  ./to-public-sync.sh areas/my-system

  # Sync single file
  ./to-public-sync.sh areas/my-system/packages.md

  # Preview mode
  ./to-public-sync.sh areas/my-system --dry-run

Behavior:
  - Source: /home/nadle/문서/google-drive-obsidian/[PATH]
  - Destination: /home/nadle/문서/google-drive-obsidian/public/[PATH without first segment]
  - First path segment (resources/, areas/, projects/, etc.) is removed
  - Folders: Recursive sync with rsync --delete
  - Files: Copy single file only

Path Examples:
  resources/book-summaries/foo → public/book-summaries/foo
  areas/my-system/packages.md → public/my-system/packages.md
EOF
}

# 메인 함수
main() {
  log_section "To-Public Sync Started"

  # 경로 인자 확인
  if [ -z "${TARGET_PATH:-}" ]; then
    log_error "No path specified"
    print_help
    exit 1
  fi

  # 첫 번째 경로 세그먼트 제거 (resources/, areas/, projects/ 등)
  RELATIVE_PATH="${TARGET_PATH#*/}"

  # 절대 경로 구성
  SOURCE_PATH="$OBSIDIAN_VAULT/$TARGET_PATH"
  DEST_PATH="$PUBLIC_DIR/$RELATIVE_PATH"

  log_info "Source: $SOURCE_PATH"
  log_info "Destination: $DEST_PATH"
  log_info "Removed first segment: ${TARGET_PATH%%/*}/"

  if [ "$DRY_RUN" = true ]; then
    log_warning "DRY-RUN MODE: No changes will be made"
  fi

  # 소스 존재 확인
  if [ ! -e "$SOURCE_PATH" ]; then
    log_error "Source does not exist: $SOURCE_PATH"
    exit 1
  fi

  # 폴더인지 파일인지 확인
  if [ -d "$SOURCE_PATH" ]; then
    log_info "Type: Directory (recursive sync)"
    sync_directory "$SOURCE_PATH" "$DEST_PATH"
  elif [ -f "$SOURCE_PATH" ]; then
    log_info "Type: File (single file copy)"
    sync_single_file "$SOURCE_PATH" "$DEST_PATH"
  else
    log_error "Unknown file type: $SOURCE_PATH"
    exit 1
  fi

  log_success "Sync completed!"
}

# 단일 파일 동기화 (이미지 처리 포함)
sync_single_file() {
  local source="$1"
  local dest="$2"
  local dest_attachments="$PUBLIC_DIR/attachments"

  log_section "Processing Single File"

  # 1단계: Obsidian 이미지 추출
  log_info "Extracting images from file..."
  local images=$(extract_obsidian_images "$source")

  if [ -n "$images" ]; then
    # 2단계: 이미지를 public/attachments로 복사
    log_info "Copying images to public/attachments..."
    local source_attachments="$OBSIDIAN_VAULT/resources/attachments"

    if [ "$DRY_RUN" = false ]; then
      if copy_multiple_images "$images" "$source_attachments" "$dest_attachments"; then
        log_success "Images copied successfully"
      else
        log_error "Failed to copy some images"
        return 1
      fi
    else
      log_info "[DRY-RUN] Would copy images to: $dest_attachments"
    fi
  else
    log_info "No images found in file"
  fi

  # 3단계: 파일 복사
  log_info "Copying file to public folder..."
  if [ "$DRY_RUN" = false ]; then
    if sync_file "$source" "$dest" "false"; then
      log_success "File copied successfully"
    else
      log_error "Failed to copy file"
      return 1
    fi
  else
    log_info "[DRY-RUN] Would copy file to: $dest"
    return 0
  fi

}

# 폴더 동기화 (이미지 처리 포함)
sync_directory() {
  local source="$1"
  local dest="$2"
  local dest_attachments="$PUBLIC_DIR/attachments"

  log_section "Syncing Directory"

  # 1단계: 폴더 동기화
  if [ "$DRY_RUN" = false ]; then
    if ! sync_folder "$source" "$dest" "false"; then
      log_error "Failed to sync folder"
      return 1
    fi
    log_success "Folder synced successfully"
  else
    log_info "[DRY-RUN] Would sync folder to: $dest"
  fi

  # 2단계: 동기화된 폴더의 모든 .md 파일 처리
  log_section "Processing Images in Folder"

  if [ "$DRY_RUN" = false ]; then
    while IFS= read -r md_file; do
      if [ -z "$md_file" ]; then
        continue
      fi

      log_info "Processing: $md_file"

      # 이미지 추출
      local images=$(extract_obsidian_images "$md_file")

      if [ -n "$images" ]; then
        # 이미지 복사
        local source_attachments="$OBSIDIAN_VAULT/resources/attachments"
        if copy_multiple_images "$images" "$source_attachments" "$dest_attachments"; then
          log_success "Images copied for: $(basename "$md_file")"
        else
          log_error "Failed to copy images for: $(basename "$md_file")"
        fi
      fi
    done < <(find "$dest" -type f -name "*.md")
  else
    log_info "[DRY-RUN] Would process images in all .md files"
  fi
}

# 스크립트 실행
main "$@"
