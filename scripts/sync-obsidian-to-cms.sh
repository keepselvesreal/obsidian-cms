#!/bin/bash

# ============================================================
# Sync Obsidian to CMS Main Script
# Obsidian vault에서 content 폴더로 동기화합니다.
# ============================================================

set -euo pipefail

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
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
  --help                이 헬프 메시지 출력

Examples:
  # 폴더 동기화 (resources/books 내 모든 파일)
  ./sync-obsidian-to-cms.sh resources/books/the-art-of-unit-testing

  # 단일 파일 동기화
  ./sync-obsidian-to-cms.sh resources/posts/첫번째게시물.md

  # 드라이런 모드
  ./sync-obsidian-to-cms.sh resources/books/도메인-주도-개발-시작하기 --dry-run

Source 경로:
  resources/books       → content/books
  resources/web-contents → content/web-contents
  resources/posts       → content/posts
  resources/attachments → content/attachments

Link 처리:
  - [[...]] 링크는 모두 제거
  - references 필드 (posts만) → 지정된 노트만 동기화
  - ![...] 이미지 → content/attachments로 복사

EOF
}

# ============================================================
# 함수: 경로를 절대 경로로 변환
# 입력: $1 = 상대 또는 절대 경로
# 출력: 절대 경로
# ============================================================
convert_to_absolute_path() {
  local path="$1"

  # 이미 절대 경로면 그대로 반환
  if [[ "$path" == /* ]]; then
    echo "$path"
    return 0
  fi

  # Vault 내 상대 경로면 vault 경로와 결합
  local abs_path="$OBSIDIAN_VAULT/$path"

  echo "$abs_path"
  return 0
}

# ============================================================
# 메인 함수
# ============================================================
main() {
  local source_path="$1"
  local dry_run=false

  # 옵션 처리
  while [[ $# -gt 1 ]]; do
    case "$2" in
      --dry-run)
        dry_run=true
        shift
        ;;
      --help)
        print_help
        exit 0
        ;;
      *)
        log_error "Unknown option: $2"
        print_help
        exit 1
        ;;
    esac
  done

  log_section "Sync Obsidian to CMS"

  # ============================================================
  # 1. 경로 검증 및 절대 경로 변환
  # ============================================================

  # 경로 인자 확인
  if [ -z "$source_path" ]; then
    log_error "Source path is required"
    print_help
    exit 1
  fi

  # 절대 경로로 변환
  local abs_path
  abs_path=$(convert_to_absolute_path "$source_path")

  log_info "Source: $abs_path"

  if [ "$dry_run" = true ]; then
    log_warning "DRY-RUN MODE: No changes will be made"
  fi

  # ============================================================
  # 2. 파일 또는 폴더 여부 판단 및 동기화
  # ============================================================

  if [ ! -e "$abs_path" ]; then
    log_error "Source does not exist: $abs_path"
    exit 1
  fi

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
    exit 1
  fi

  log_success "Sync completed!"
}

# ============================================================
# 스크립트 실행
# ============================================================

if [ $# -lt 1 ]; then
  print_help
  exit 1
fi

main "$@"
