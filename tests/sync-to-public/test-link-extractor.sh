#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-links-$$"

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
  source "$SCRIPT_DIR/lib/link-extractor.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT"
  mkdir -p "$TEST_VAULT"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # 픽스처 1: 여러 링크 포함
  cat > "$TEST_VAULT/file-with-links.md" << 'EOF'
# File with Links

[[resources/test/test-image-copy|test-image-copy]]

Some content here.

[[areas/my-system/packages|packages]]

More content.
EOF

  # 픽스처 2: 링크 없음
  cat > "$TEST_VAULT/file-without-links.md" << 'EOF'
# File without Links

No links here.
EOF

  # 픽스처 3: 링크 표시 텍스트 없음
  cat > "$TEST_VAULT/file-with-simple-link.md" << 'EOF'
[[resources/simple-note]]
EOF

  test_pass "Fixtures created"
}

# 테스트 1: 여러 링크 추출
test_extract_multiple_links() {
  test_info "Test 1: Extract multiple links"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/file-with-links.md"
  local links=$(extract_obsidian_links "$file")

  local count=$(echo "$links" | grep -c . || true)

  if [ "$count" -eq 2 ]; then
    test_pass "Multiple links extracted (found $count links)"
  else
    test_fail "Expected 2 links, found $count"
  fi
}

# 테스트 2: 링크 경로 추출 정확성
test_link_format() {
  test_info "Test 2: Verify link format"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/file-with-links.md"
  local links=$(extract_obsidian_links "$file")

  if echo "$links" | grep -q "resources/test/test-image-copy|test-image-copy"; then
    test_pass "Link format correct (path|text)"
  else
    test_fail "Link format not correct"
  fi
}

# 테스트 3: 링크 없는 파일
test_no_links() {
  test_info "Test 3: File without links"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/file-without-links.md"
  local links=$(extract_obsidian_links "$file")

  if [ -z "$links" ]; then
    test_pass "No links extracted from file without links"
  else
    test_fail "Unexpectedly found links: $links"
  fi
}

# 테스트 4: 단순 링크 추출 (텍스트 없음)
test_simple_link() {
  test_info "Test 4: Extract simple link (no text)"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/file-with-simple-link.md"
  local links=$(extract_obsidian_links "$file")

  if echo "$links" | grep -q "resources/simple-note"; then
    test_pass "Simple link extracted correctly"
  else
    test_fail "Simple link not extracted"
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
  echo "Link Extractor Test Results"
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
  echo "TDD: Link Extractor Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_extract_multiple_links
  test_link_format
  test_no_links
  test_simple_link

  cleanup
  report_results
}

main "$@"
