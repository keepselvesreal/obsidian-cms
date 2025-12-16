#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-find-in-public-$$"

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../scripts" && pwd)"

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_info() {
  echo -e "${YELLOW}[TEST]${NC} $1"
}

test_pass() {
  echo -e "${GREEN}✓${NC} $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
  echo -e "${RED}✗${NC} $1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

# 라이브러리 로드
load_libraries() {
  source "$SCRIPT_DIR/lib/find-in-public.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT"
  mkdir -p "$TEST_VAULT/public/test"
  mkdir -p "$TEST_VAULT/public/book-summaries/a-philosophy"
  mkdir -p "$TEST_VAULT/public/resources"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # 테스트 파일들 생성
  cat > "$TEST_VAULT/public/test/test-image-copy.md" << 'EOF'
# Test Image
EOF

  cat > "$TEST_VAULT/public/book-summaries/a-philosophy/summary-ch04.md" << 'EOF'
# Chapter 4
EOF

  cat > "$TEST_VAULT/public/resources/package-notes.md" << 'EOF'
# Packages
EOF

  test_pass "Fixtures created"
}

# 테스트 1: 파일이 public에 존재 - 단순 파일명
test_find_simple_filename() {
  test_info "Test 1: Find file by simple filename"
  TESTS_RUN=$((TESTS_RUN + 1))

  local result=$(find_in_public "test-image-copy" "$TEST_VAULT/public" 2>/dev/null)

  if [ "$result" = "public/test/test-image-copy" ]; then
    test_pass "Found file with simple filename"
  else
    test_fail "Failed to find file (got: $result)"
  fi
}

# 테스트 2: 파일명에 .md 포함
test_find_with_md_extension() {
  test_info "Test 2: Find file by filename with .md extension"
  TESTS_RUN=$((TESTS_RUN + 1))

  local result=$(find_in_public "test-image-copy.md" "$TEST_VAULT/public" 2>/dev/null)

  if [ "$result" = "public/test/test-image-copy" ]; then
    test_pass "Found file with .md extension in query"
  else
    test_fail "Failed to find file (got: $result)"
  fi
}

# 테스트 3: 파일이 없을 경우
test_find_nonexistent_file() {
  test_info "Test 3: File does not exist"
  TESTS_RUN=$((TESTS_RUN + 1))

  if ! find_in_public "nonexistent-file" "$TEST_VAULT/public" 2>/dev/null; then
    test_pass "Correctly returned error for non-existent file"
  else
    test_fail "Should have returned error for non-existent file"
  fi
}

# 테스트 4: 중첩된 폴더의 파일 찾기
test_find_nested_file() {
  test_info "Test 4: Find file in nested folders"
  TESTS_RUN=$((TESTS_RUN + 1))

  local result=$(find_in_public "summary-ch04" "$TEST_VAULT/public" 2>/dev/null)

  if [ "$result" = "public/book-summaries/a-philosophy/summary-ch04" ]; then
    test_pass "Found file in nested folder"
  else
    test_fail "Failed to find nested file (got: $result)"
  fi
}

# 테스트 5: public 폴더가 없을 경우
test_find_no_public_folder() {
  test_info "Test 5: Public folder does not exist"
  TESTS_RUN=$((TESTS_RUN + 1))

  if ! find_in_public "test-image-copy" "/nonexistent/public" 2>/dev/null; then
    test_pass "Correctly handled missing public folder"
  else
    test_fail "Should have returned error for missing public folder"
  fi
}

# 테스트 6: 정확한 파일명 매칭 (부분 일치 제외)
test_find_exact_match_only() {
  test_info "Test 6: Exact filename match only"
  TESTS_RUN=$((TESTS_RUN + 1))

  # "test-image"는 "test-image-copy.md"와 다름
  if ! find_in_public "test-image" "$TEST_VAULT/public" 2>/dev/null; then
    test_pass "Correctly rejected partial match"
  else
    test_fail "Should have rejected partial filename match"
  fi
}

# 정리
cleanup() {
  test_info "Cleaning up test environment..."
  rm -rf "$TEST_VAULT"
  test_pass "Test environment cleaned up"
}

# 결과 리포트
report_results() {
  echo ""
  echo "================================"
  echo "Find in Public Test Results"
  echo "================================"
  echo "Total tests run:  $TESTS_RUN"
  echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
  echo "================================"

  if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    return 0
  else
    echo -e "${RED}Some tests failed!${NC}"
    return 1
  fi
}

# 메인
main() {
  echo "========================================="
  echo "TDD: Find in Public Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_find_simple_filename
  test_find_with_md_extension
  test_find_nonexistent_file
  test_find_nested_file
  test_find_no_public_folder
  test_find_exact_match_only

  cleanup
  report_results
}

main "$@"
