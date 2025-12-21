#!/bin/bash

# ============================================================
# Options Parser Library
# 모든 스크립트에서 사용하는 옵션 처리를 통일합니다
# ============================================================

# ============================================================
# 함수: 옵션 파싱
# 입력: $1 = 옵션 배열명 (참조), $@ = 파싱할 인자
# 출력: 옵션 배열 설정
# ============================================================
parse_options() {
  local opts_var="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        eval "${opts_var}[dry_run]=true"
        shift
        ;;
      --verbose)
        eval "${opts_var}[verbose]=true"
        shift
        ;;
      --test-*)
        # 테스트 모드 옵션
        eval "${opts_var}[test_mode]=true"
        eval "${opts_var}[test_target]=\"${1#--test-}\""
        shift
        ;;
      --help)
        eval "${opts_var}[help]=true"
        shift
        ;;
      *)
        return 1
        ;;
    esac
  done

  return 0
}

# ============================================================
# 함수: 기본 옵션 배열 초기화
# 출력: 옵션 배열 생성
# ============================================================
init_options() {
  local opts_var="$1"

  eval "${opts_var}[dry_run]=false"
  eval "${opts_var}[verbose]=false"
  eval "${opts_var}[help]=false"
  eval "${opts_var}[test_mode]=false"
  eval "${opts_var}[test_target]=\"\""

  return 0
}

# ============================================================
# 함수: 옵션 검증
# 입력: $1 = 옵션 배열명
# 출력: 0 = 유효, 1 = 무효
# ============================================================
validate_options() {
  local opts_var="$1"

  # test_mode와 dry_run은 함께 사용할 수 없음
  local test_mode dry_run
  eval "test_mode=\${${opts_var}[test_mode]}"
  eval "dry_run=\${${opts_var}[dry_run]}"

  if [ "$test_mode" = true ] && [ "$dry_run" = true ]; then
    return 1
  fi

  return 0
}

# ============================================================
# 함수: 옵션 출력
# 입력: $1 = 옵션 배열명 (verbose 모드일 때만)
# ============================================================
print_options() {
  local opts_var="$1"

  local verbose
  eval "verbose=\${${opts_var}[verbose]}"

  if [ "$verbose" = true ]; then
    local dry_run test_mode test_target
    eval "dry_run=\${${opts_var}[dry_run]}"
    eval "test_mode=\${${opts_var}[test_mode]}"
    eval "test_target=\${${opts_var}[test_target]}"

    log_debug "Options:"
    log_debug "  dry_run: $dry_run"
    log_debug "  verbose: $verbose"
    log_debug "  test_mode: $test_mode"
    log_debug "  test_target: $test_target"
  fi
}
