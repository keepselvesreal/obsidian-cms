#!/bin/bash

# ============================================================
# Sync Single File Script (Refactored)
# 단일 마크다운 파일을 CMS로 동기화합니다.
# ============================================================

set -u

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/options-parser.sh"
source "$SCRIPT_DIR/lib/path-resolver.sh"
source "$SCRIPT_DIR/lib/error-handler.sh"
source "$SCRIPT_DIR/lib/link-remover.sh"
source "$SCRIPT_DIR/lib/image-handler.sh"
source "$SCRIPT_DIR/lib/reference-handler.sh"
source "$SCRIPT_DIR/lib/test-mode-handler.sh"
source "$SCRIPT_DIR/lib/yaml-parser.sh"
source "$SCRIPT_DIR/config.sh"

# ============================================================
# 함수: 파일을 content로 복사
# 입력: $1 = 원본 파일, $2 = 대상 폴더, $3 = DRY_RUN (선택사항)
# ============================================================
copy_markdown_file() {
  local source="$1"
  local dest_folder="$2"
  local dry_run="${3:-false}"

  log_debug "copy_markdown_file: $source → $dest_folder"

  local filename
  filename=$(basename "$source")

  if [ "$dry_run" = false ]; then
    # 임시 파일 생성 (링크 제거 후)
    local temp_file
    temp_file=$(mktemp)
    cleanup_on_exit "$temp_file"

    cp "$source" "$temp_file"

    # 링크 제거
    if has_obsidian_links "$temp_file"; then
      log_info "Removing obsidian links..."
      remove_obsidian_links "$temp_file"
      log_success "Links removed"
    fi

    # 파일 복사
    local dest_file
    dest_file=$(get_destination_file_path "$source" "$(get_resource_type "$source")")
    mkdir -p "$(dirname "$dest_file")"
    mv "$temp_file" "$dest_file"
    log_success "File copied: $(basename "$dest_file")"
  else
    log_info "[DRY-RUN] Would copy file with links removed: $filename"
  fi
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
        # 옵션 인자는 다음에 처리
        break
        ;;
      *)
        # 첫 번째 비옵션 인자
        source_path="$1"
        shift
        break
        ;;
    esac
  done

  if [ -z "$source_path" ]; then
    log_error "Source file is required"
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

  log_section "Syncing Single File"

  log_info "Source: $source_path"

  # ============================================================
  # 1. 유효성 검사
  # ============================================================

  if ! validate_path "$source_path"; then
    return 1
  fi

  # ============================================================
  # 2. 테스트 모드 처리
  # ============================================================

  local test_mode
  eval "test_mode=\${opts[test_mode]}"
  if [ "$test_mode" = true ]; then
    run_test_mode "opts" "$source_path"
    return $?
  fi

  # ============================================================
  # 3. 리소스 타입 판단
  # ============================================================

  local resource_type
  if ! resource_type=$(get_resource_type "$source_path"); then
    log_error "File is not in any recognized source folder"
    log_error "Expected: $BOOKS_SOURCE, $WEB_CONTENTS_SOURCE, or $POSTS_SOURCE"
    return 1
  fi

  local dest_folder
  dest_folder=$(get_destination_folder "$resource_type")
  log_info "Destination: $dest_folder ($resource_type)"

  # ============================================================
  # 4. 파일 복사
  # ============================================================

  local dry_run
  eval "dry_run=\${opts[dry_run]}"

  log_section "Copying File"
  copy_markdown_file "$source_path" "$dest_folder" "$dry_run"

  # ============================================================
  # 5. 이미지 동기화
  # ============================================================

  sync_all_images "$source_path" "$dry_run"

  # ============================================================
  # 6. References 동기화 (posts만)
  # ============================================================

  if [ "$resource_type" = "posts" ]; then
    log_section "Syncing References"
    sync_referenced_files "$source_path" "$dry_run"
  fi

  log_success "File sync completed!"
  return 0
}

# ============================================================
# 헬프 메시지
# ============================================================
print_help() {
  cat << 'EOF'
Usage: ./sync-single-file.sh <SOURCE_FILE> [OPTIONS]

Arguments:
  SOURCE_FILE               마크다운 파일 절대 경로

Options:
  --dry-run                 실제 복사 없이 시뮬레이션만 실행
  --verbose                 상세 로그 출력 (DEBUG 로그 포함)
  --test-[target]           특정 함수 테스트 모드
  --help                    이 헬프 메시지 출력

Test Targets:
  --test-path-resolver      경로 해석 테스트
  --test-link-remover       링크 제거 테스트
  --test-image-extraction   이미지 추출 테스트
  --test-reference-extraction 참조 추출 테스트

Examples:
  # 파일 동기화
  ./sync-single-file.sh /path/to/file.md

  # 드라이런 모드
  ./sync-single-file.sh /path/to/file.md --dry-run

  # Verbose 로그
  ./sync-single-file.sh /path/to/file.md --verbose

  # 테스트 모드
  ./sync-single-file.sh /path/to/file.md --test-path-resolver
  ./sync-single-file.sh /path/to/file.md --test-image-extraction

EOF
}

# ============================================================
# 스크립트 실행
# ============================================================

if [ $# -lt 1 ] || [ "$1" = "--help" ]; then
  print_help
  exit 0
fi

main "$@"
