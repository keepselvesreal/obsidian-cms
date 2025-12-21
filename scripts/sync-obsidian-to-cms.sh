#!/bin/bash

# ============================================================
# Sync Obsidian to CMS Main Script (Refactored)
# Obsidian vault에서 content 폴더로 동기화합니다.
# ============================================================

set -u

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/options-parser.sh"
source "$SCRIPT_DIR/lib/path-resolver.sh"
source "$SCRIPT_DIR/lib/error-handler.sh"
source "$SCRIPT_DIR/config.sh"

# ============================================================
# 함수: 헬프 출력
# ============================================================
print_help() {
  cat << 'EOF'
Usage: ./sync-obsidian-to-cms.sh <SOURCE> [OPTIONS]

Arguments:
  SOURCE                Obsidian vault 내 상대 경로 또는 절대 경로
                        - Folder: 폴더 내 모든 마크다운 파일 동기화
                        - File: 단일 마크다운 파일 동기화

Options:
  --dry-run             실제 복사 없이 시뮬레이션만 실행
  --verbose             상세 로그 출력 (DEBUG 로그 포함)
  --help                이 헬프 메시지 출력

Examples:
  # 폴더 동기화 (resources/books 내 모든 파일)
  ./sync-obsidian-to-cms.sh resources/books/the-art-of-unit-testing

  # 단일 파일 동기화
  ./sync-obsidian-to-cms.sh resources/posts/첫번째게시물.md

  # 드라이런 모드
  ./sync-obsidian-to-cms.sh resources/books/도메인-주도-개발-시작하기 --dry-run

  # Verbose 모드
  ./sync-obsidian-to-cms.sh resources/posts/파일.md --verbose

Source 경로:
  resources/books       → content/books
  resources/web-contents → content/web-contents
  resources/posts       → content/posts
  resources/attachments → content/attachments

Link 처리:
  - [[...]] 링크는 모두 제거 (![[...]]는 보존)
  - references 필드 (posts만) → 지정된 노트만 동기화
  - ![...] 이미지 → content/attachments로 복사

EOF
}

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

  local source_path=""

  # 첫 번째 비옵션 인자를 source_path로 설정
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --*)
        break
        ;;
      *)
        source_path="$1"
        shift
        break
        ;;
    esac
  done

  if [ -z "$source_path" ]; then
    log_error "Source path is required"
    print_help
    return 1
  fi

  # 옵션 파싱
  if ! parse_options "opts" "$@"; then
    log_error "Failed to parse options"
    return 1
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

  log_section "Sync Obsidian to CMS"

  # ============================================================
  # 1. 경로 검증 및 절대 경로 변환
  # ============================================================

  log_info "Source (relative): $source_path"

  # 절대 경로로 변환
  local abs_path
  abs_path=$(resolve_to_absolute_path "$source_path")

  log_info "Source (absolute): $abs_path"

  # 경로 검증
  if ! validate_path "$abs_path"; then
    return 1
  fi

  # dry-run 모드 출력
  local dry_run
  eval "dry_run=\${opts[dry_run]}"
  if [ "$dry_run" = true ]; then
    log_warning "DRY-RUN MODE: No changes will be made"
  fi

  # ============================================================
  # 2. 파일 또는 폴더 여부 판단 및 동기화
  # ============================================================

  # VERBOSE 환경변수 설정
  [ "$verbose" = true ] && export VERBOSE=true

  if [ -f "$abs_path" ]; then
    # 파일 동기화
    log_info "Type: File"

    if [ "$dry_run" = true ]; then
      "$SCRIPT_DIR/sync-single-file.sh" "$abs_path" --dry-run
    else
      "$SCRIPT_DIR/sync-single-file.sh" "$abs_path"
    fi

  elif [ -d "$abs_path" ]; then
    # 폴더 동기화
    log_info "Type: Directory"

    if [ "$dry_run" = true ]; then
      "$SCRIPT_DIR/sync-directory.sh" "$abs_path" --dry-run
    else
      "$SCRIPT_DIR/sync-directory.sh" "$abs_path"
    fi

  else
    log_error "Unknown file type: $abs_path"
    return 1
  fi

  log_success "Sync completed!"
  return 0
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
