#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-resolver-$$"

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
  source "$SCRIPT_DIR/lib/link-resolver.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT"
  mkdir -p "$TEST_VAULT/resources/test"
  mkdir -p "$TEST_VAULT/areas/my-system"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # 링크될 파일들 생성
  cat > "$TEST_VAULT/resources/test/test-image-copy.md" << 'EOF'
# Test Image Copy
![[image.png]]
EOF

  cat > "$TEST_VAULT/areas/my-system/packages.md" << 'EOF'
# Packages
EOF

  cat > "$TEST_VAULT/resources/simple-note.md" << 'EOF'
# Simple Note
EOF

  test_pass "Fixtures created"
}

# 테스트 1: 경로|텍스트 형식 해석
test_resolve_with_text() {
  test_info "Test 1: Resolve link with text (path|text format)"
  TESTS_RUN=$((TESTS_RUN + 1))

  local link="resources/test/test-image-copy|test-image-copy"
  local result=$(resolve_link "$link" "$TEST_VAULT" 2>/dev/null)

  if [ "$result" = "$TEST_VAULT/resources/test/test-image-copy.md" ]; then
    test_pass "Link resolved correctly with text"
  else
    test_fail "Link resolution failed (got: $result)"
  fi
}

# 테스트 2: 경로만 있는 형식 해석
test_resolve_without_text() {
  test_info "Test 2: Resolve link without text"
  TESTS_RUN=$((TESTS_RUN + 1))

  local link="resources/simple-note"
  local result=$(resolve_link "$link" "$TEST_VAULT" 2>/dev/null)

  if [ "$result" = "$TEST_VAULT/resources/simple-note.md" ]; then
    test_pass "Link resolved correctly without text"
  else
    test_fail "Link resolution failed (got: $result)"
  fi
}

# 테스트 3: 폴더 경로 포함 링크
test_resolve_with_folder() {
  test_info "Test 3: Resolve link with folder path"
  TESTS_RUN=$((TESTS_RUN + 1))

  local link="areas/my-system/packages|packages"
  local result=$(resolve_link "$link" "$TEST_VAULT" 2>/dev/null)

  if [ "$result" = "$TEST_VAULT/areas/my-system/packages.md" ]; then
    test_pass "Link with folder path resolved correctly"
  else
    test_fail "Link resolution failed (got: $result)"
  fi
}

# 테스트 4: 경로 없음 (오류)
test_resolve_no_path() {
  test_info "Test 4: Link with no path (error)"
  TESTS_RUN=$((TESTS_RUN + 1))

  local link="|display-text"

  if ! resolve_link "$link" "$TEST_VAULT" 2>/dev/null; then
    test_pass "Correctly rejected link with no path"
  else
    test_fail "Should have rejected link with no path"
  fi
}

# 테스트 5: 파일 없음 (오류)
test_resolve_file_not_found() {
  test_info "Test 5: Link to non-existent file (error)"
  TESTS_RUN=$((TESTS_RUN + 1))

  local link="resources/non-existent|text"

  if ! resolve_link "$link" "$TEST_VAULT" 2>/dev/null; then
    test_pass "Correctly rejected link to non-existent file"
  else
    test_fail "Should have rejected link to non-existent file"
  fi
}

# 테스트 6: .md 확장자 자동 추가
test_resolve_auto_md_extension() {
  test_info "Test 6: Auto-add .md extension"
  TESTS_RUN=$((TESTS_RUN + 1))

  local link="resources/test/test-image-copy.md|text"
  local result=$(resolve_link "$link" "$TEST_VAULT" 2>/dev/null)

  if [ "$result" = "$TEST_VAULT/resources/test/test-image-copy.md" ]; then
    test_pass "Correctly handled .md extension"
  else
    test_fail "Failed to handle .md extension (got: $result)"
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
  echo "Link Resolver Test Results"
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
  echo "TDD: Link Resolver Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_resolve_with_text
  test_resolve_without_text
  test_resolve_with_folder
  test_resolve_no_path
  test_resolve_file_not_found
  test_resolve_auto_md_extension

  cleanup
  report_results
}

main "$@"
