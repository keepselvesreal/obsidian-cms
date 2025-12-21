#!/bin/bash

# ============================================================
# Sync Directory Script (Refactored)
# 폴더 내의 모든 마크다운 파일을 CMS로 동기화합니다.
# ============================================================

set -u

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/options-parser.sh"
source "$SCRIPT_DIR/lib/error-handler.sh"
source "$SCRIPT_DIR/lib/path-resolver.sh"
source "$SCRIPT_DIR/lib/image-handler.sh"
source "$SCRIPT_DIR/lib/index-generator.sh"
source "$SCRIPT_DIR/config.sh"

# ============================================================
# 메인 함수
# ============================================================
main() {
  local -A opts=(
    [dry_run]=false
    [verbose]=false
    [help]=false
    [test_mode]=false
    [test_target]=""
  )

  if [ $# -lt 1 ]; then
    log_error "Usage: $0 <SOURCE_FOLDER> [OPTIONS]"
    return 1
  fi

  local source_folder="$1"
  shift

  # 옵션 파싱 (옵션이 있을 때만)
  if [ $# -gt 0 ]; then
    if ! parse_options "opts" "$@"; then
      log_error "Failed to parse options"
      return 1
    fi
  fi

  # 옵션 검증
  if ! validate_options "opts"; then
    log_error "Invalid option combination"
    return 1
  fi

  # Verbose 모드 설정
  local verbose
  eval "verbose=\${opts[verbose]}"
  [ "$verbose" = true ] && VERBOSE=true

  log_section "Syncing Directory"
  log_info "Source: $source_folder"

  # ============================================================
  # 1. 유효성 검사
  # ============================================================

  log_info "Validating folder..."

  if [ ! -d "$source_folder" ]; then
    log_error "Folder does not exist: $source_folder"
    return 1
  fi

  if [[ "$source_folder" != "$OBSIDIAN_VAULT"* ]]; then
    log_error "Folder must be inside Obsidian vault: $OBSIDIAN_VAULT"
    return 1
  fi

  if [[ "$source_folder" == "$CONTENT_DIR"* ]]; then
    log_error "Cannot sync folder from content folder: $source_folder"
    return 1
  fi

  log_success "Validation passed"

  # ============================================================
  # 2. 폴더 내 마크다운 파일 찾기 및 동기화
  # ============================================================

  log_section "Finding and Syncing Markdown Files"

  local success_count=0
  local failed_count=0
  local total_files=0

  # 파일 개수 계산
  total_files=$(find "$source_folder" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)

  if [ "$total_files" -eq 0 ]; then
    log_warning "No markdown files found in folder"
    log_section "Sync Summary"
    log_success "Completed: 0 files processed"
    return 0
  fi

  log_success "Found $total_files markdown file(s)"
  log_info "Starting sync process..."

  # 임시 파일에 파일 목록 저장
  local temp_file_list
  temp_file_list=$(mktemp)
  cleanup_on_exit "$temp_file_list"
  find "$source_folder" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort > "$temp_file_list"

  # 각 파일 처리
  local file_index=0
  local dry_run
  eval "dry_run=\${opts[dry_run]}"

  while IFS= read -r md_file; do
    # 빈 라인 제외
    [ -z "$md_file" ] && continue

    ((file_index++))

    local filename
    filename=$(basename "$md_file")

    log_info "[$file_index/$total_files] Syncing: $filename"
    log_debug "Full path: $md_file"

    local sync_result=0
    if [ "$dry_run" = true ]; then
      "$SCRIPT_DIR/sync-single-file.sh" "$md_file" --dry-run 2>&1 | grep -v "^========" | grep -v "^\[" || sync_result=1
      if [ "$sync_result" -eq 0 ]; then
        log_success "  ✓ Processed (dry-run): $filename"
        ((success_count++))
      else
        log_error "  ✗ Failed (dry-run): $filename"
        ((failed_count++))
      fi
    else
      "$SCRIPT_DIR/sync-single-file.sh" "$md_file" 2>&1 | grep -v "^========" | grep -v "^\[" || sync_result=1
      if [ "$sync_result" -eq 0 ]; then
        log_success "  ✓ Synced: $filename"
        ((success_count++))
      else
        log_error "  ✗ Failed: $filename"
        ((failed_count++))
      fi
    fi
  done < "$temp_file_list"

  rm -f "$temp_file_list"

  # ============================================================
  # 3. Cover 복사 및 Index 파일 생성
  # ============================================================

  if [ "$dry_run" = false ] && [ "$failed_count" -eq 0 ]; then
    log_section "Generating Index Files"

    # 대상 폴더 계산
    local resource_type
    if ! resource_type=$(get_resource_type "$source_folder"); then
      log_warning "Could not determine resource type for: $source_folder"
    else
      local dest_folder_name
      dest_folder_name=$(basename "$source_folder")

      local dest_base_folder
      dest_base_folder=$(get_destination_folder "$resource_type") || return 1

      local dest_folder_path="$CONTENT_DIR/$dest_base_folder/$dest_folder_name"

      if [ -d "$dest_folder_path" ]; then
        log_info "Creating index for: $dest_folder_name"

        # Cover 이미지 복사
        sync_cover_image "$source_folder" "$dest_folder_path" "$dry_run"

        # Index 생성
        generate_folder_index "$dest_folder_path"
      fi
    fi
  fi

  # ============================================================
  # 4. 결과 요약
  # ============================================================

  log_section "Sync Summary"
  log_info "Total files: $total_files"
  log_info "Succeeded: $success_count"
  log_info "Failed: $failed_count"

  if [ "$failed_count" -gt 0 ]; then
    log_error "Sync completed with errors"
    return 1
  else
    log_success "Sync completed successfully"
    return 0
  fi
}

# ============================================================
# 헬프 메시지
# ============================================================
print_help() {
  cat << 'EOF'
Usage: ./sync-directory.sh <SOURCE_FOLDER> [OPTIONS]

Arguments:
  SOURCE_FOLDER         마크다운 파일이 있는 폴더 절대 경로

Options:
  --dry-run             실제 복사 없이 시뮬레이션만 실행
  --verbose             상세 로그 출력 (DEBUG 로그 포함)
  --help                이 헬프 메시지 출력

Examples:
  # 폴더 동기화
  ./sync-directory.sh /path/to/resources/books

  # 드라이런 모드
  ./sync-directory.sh /path/to/resources/web-contents --dry-run

  # Verbose 로그
  ./sync-directory.sh /path/to/resources/posts --verbose

EOF
}

# ============================================================
# 스크립트 실행
# ============================================================

if [ $# -lt 1 ]; then
  print_help
  exit 1
fi

if [ "$1" = "--help" ]; then
  print_help
  exit 0
fi

main "$@"
