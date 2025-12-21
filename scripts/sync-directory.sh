#!/bin/bash

# ============================================================
# Sync Directory Script (Final Version - Fixed)
# 폴더 내의 모든 마크다운 파일을 CMS로 동기화합니다.
# ============================================================

set -u  # 선언되지 않은 변수 사용 시 에러

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/config.sh"

# ============================================================
# 메인 함수
# ============================================================
main() {
  local source_folder="$1"
  local dry_run=false

  # --dry-run 옵션 처리
  if [ $# -gt 1 ] && [ "$2" = "--dry-run" ]; then
    dry_run=true
  fi

  log_section "Syncing Directory"
  log_info "Source: $source_folder"
  log_info "Dry-Run: $dry_run"

  # ============================================================
  # 1. 유효성 검사
  # ============================================================

  log_info "Validating folder..."

  if [ ! -d "$source_folder" ]; then
    log_error "Folder does not exist: $source_folder"
    exit 1
  fi

  if [[ "$source_folder" != "$OBSIDIAN_VAULT"* ]]; then
    log_error "Folder must be inside Obsidian vault: $OBSIDIAN_VAULT"
    exit 1
  fi

  if [[ "$source_folder" == "$CONTENT_DIR"* ]]; then
    log_error "Cannot sync folder from content folder: $source_folder"
    exit 1
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
    exit 0
  fi

  log_success "Found $total_files markdown file(s)"
  log_info "Starting sync process..."

  # 임시 파일에 파일 목록 저장
  local temp_file_list
  temp_file_list=$(mktemp)
  find "$source_folder" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort > "$temp_file_list"

  # 각 파일 처리
  local file_index=0
  while IFS= read -r md_file; do
    # 빈 라인 제외
    [ -z "$md_file" ] && continue

    ((file_index++))

    local filename
    filename=$(basename "$md_file")

    log_info "[$file_index/$total_files] Syncing: $filename"

    local sync_result=0
    if [ "$dry_run" = true ]; then
      "$SCRIPT_DIR/sync-single-file.sh" "$md_file" --dry-run > /dev/null 2>&1 || sync_result=1
      if [ "$sync_result" -eq 0 ]; then
        log_success "  ✓ Processed (dry-run): $filename"
        ((success_count++))
      else
        log_error "  ✗ Failed (dry-run): $filename"
        ((failed_count++))
      fi
    else
      "$SCRIPT_DIR/sync-single-file.sh" "$md_file" > /dev/null 2>&1 || sync_result=1
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
  # 3. 결과 요약
  # ============================================================

  log_section "Sync Summary"
  log_info "Total files: $total_files"
  log_info "Succeeded: $success_count"
  log_info "Failed: $failed_count"

  if [ "$failed_count" -gt 0 ]; then
    log_error "Sync completed with errors"
    exit 1
  else
    log_success "Sync completed successfully"
    exit 0
  fi
}

# ============================================================
# 스크립트 실행
# ============================================================

if [ $# -lt 1 ]; then
  echo "Usage: $0 <SOURCE_FOLDER> [--dry-run]"
  echo "Examples:"
  echo "  $0 /path/to/resources/books"
  echo "  $0 /path/to/resources/web-contents --dry-run"
  exit 1
fi

main "$@"
