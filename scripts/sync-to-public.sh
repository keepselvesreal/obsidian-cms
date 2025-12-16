#!/bin/bash

set -euo pipefail

# 메인 동기화 스크립트 (sync-single-file.sh, sync-directory.sh를 호출)

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"

# 설정 파일 로드 (없으면 기본값 사용)
if [ -f "$SCRIPT_DIR/config.sh" ]; then
  source "$SCRIPT_DIR/config.sh"
else
  log_warning "config.sh not found, using default values"
  # 기본값
  OBSIDIAN_VAULT="/home/nadle/문서/google-drive-obsidian"
  PUBLIC_DIR="$OBSIDIAN_VAULT/public"
  SOURCE_ATTACHMENTS_DIR="$OBSIDIAN_VAULT/resources/attachments"
  DRY_RUN=false
  AUTO_INCLUDE_LINKS=false
fi

# Copied files tracker (unique per run)
COPIED_FILES_TRACKER="/tmp/sync-to-public-copied-$$"

# 공통 변수를 환경변수로 export (서브 스크립트에서 사용)
export SCRIPT_DIR OBSIDIAN_VAULT PUBLIC_DIR SOURCE_ATTACHMENTS_DIR DRY_RUN AUTO_INCLUDE_LINKS COPIED_FILES_TRACKER

# 옵션 처리
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --auto-include-links)
      AUTO_INCLUDE_LINKS=true
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
Usage: ./sync-to-public.sh [PATH] [OPTIONS]

Arguments:
  PATH                Relative path from Obsidian vault
                      - Folder: syncs all contents recursively
                      - File: syncs only that file

Options:
  --dry-run               Run without making changes (preview mode)
  --auto-include-links    Auto-copy linked files without user confirmation
  --help                  Show this help message

Examples:
  # Sync entire folder recursively
  ./sync-to-public.sh areas/my-system

  # Sync single file
  ./sync-to-public.sh areas/my-system/packages.md

  # Sync with auto-include linked files
  ./sync-to-public.sh resources/test/revolve-link.md --auto-include-links

  # Preview mode
  ./sync-to-public.sh areas/my-system --dry-run

Behavior:
  - Source: /home/nadle/문서/google-drive-obsidian/[PATH]
  - Destination: /home/nadle/문서/google-drive-obsidian/public/[PATH without first segment]
  - First path segment (resources/, areas/, projects/, etc.) is removed
  - Folders: Recursive sync with rsync --delete
  - Files: Copy single file + linked files (if --auto-include-links)

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

  # 추적 파일 초기화
  > "$COPIED_FILES_TRACKER"

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

  if [ "$AUTO_INCLUDE_LINKS" = true ]; then
    log_info "AUTO-INCLUDE LINKS: Linked files will be copied automatically"
  fi

  # 소스 존재 확인
  if [ ! -e "$SOURCE_PATH" ]; then
    log_error "Source does not exist: $SOURCE_PATH"
    exit 1
  fi

  # 폴더인지 파일인지 확인
  if [ -d "$SOURCE_PATH" ]; then
    log_info "Type: Directory (recursive sync)"
    "$SCRIPT_DIR/sync-directory.sh" "$SOURCE_PATH" "$DEST_PATH"
  elif [ -f "$SOURCE_PATH" ]; then
    log_info "Type: File (single file copy)"
    "$SCRIPT_DIR/sync-single-file.sh" "$SOURCE_PATH" "$DEST_PATH"
  else
    log_error "Unknown file type: $SOURCE_PATH"
    exit 1
  fi

  log_success "Sync completed!"

  # 정리
  rm -f "$COPIED_FILES_TRACKER"
}

# 스크립트 실행
main "$@"
