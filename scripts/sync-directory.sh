#!/bin/bash

# ============================================================
# Sync Directory Script
# 폴더 내의 모든 마크다운 파일을 CMS로 동기화합니다.
# ============================================================

set -euo pipefail

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

  # ============================================================
  # 1. 유효성 검사
  # ============================================================

  # 폴더 존재 여부
  if [ ! -d "$source_folder" ]; then
    log_error "Folder does not exist: $source_folder"
    exit 1
  fi

  # Obsidian vault 내에 있는지 확인
  if [[ "$source_folder" != "$OBSIDIAN_VAULT"* ]]; then
    log_error "Folder must be inside Obsidian vault: $OBSIDIAN_VAULT"
    exit 1
  fi

  # 폴더가 content 폴더 내에 있는지 확인
  if [[ "$source_folder" == "$CONTENT_DIR"* ]]; then
    log_error "Cannot sync folder from content folder: $source_folder"
    exit 1
  fi

  # ============================================================
  # 2. 폴더 내 모든 .md 파일 찾기
  # ============================================================

  log_info "Finding markdown files in folder..."

  local md_files=()
  while IFS= read -r md_file; do
    md_files+=("$md_file")
  done < <(find "$source_folder" -type f -name "*.md" | sort)

  if [ ${#md_files[@]} -eq 0 ]; then
    log_warning "No markdown files found in folder"
    exit 0
  fi

  log_success "Found ${#md_files[@]} markdown file(s)"

  # ============================================================
  # 3. 각 파일 동기화
  # ============================================================

  log_section "Syncing Files"

  local failed_count=0
  local success_count=0

  for md_file in "${md_files[@]}"; do
    # 파일을 sync-single-file.sh로 동기화
    if [ "$dry_run" = true ]; then
      if "$SCRIPT_DIR/sync-single-file.sh" "$md_file" --dry-run; then
        ((success_count++))
      else
        ((failed_count++))
        log_error "Failed to process: $(basename "$md_file")"
      fi
    else
      if "$SCRIPT_DIR/sync-single-file.sh" "$md_file"; then
        ((success_count++))
      else
        ((failed_count++))
        log_error "Failed to sync: $(basename "$md_file")"
      fi
    fi
  done

  # ============================================================
  # 4. 결과 요약
  # ============================================================

  log_section "Sync Summary"

  if [ $failed_count -gt 0 ]; then
    log_error "Sync completed with errors: $success_count succeeded, $failed_count failed"
    exit 1
  else
    log_success "Sync completed successfully: $success_count file(s) synced"
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
