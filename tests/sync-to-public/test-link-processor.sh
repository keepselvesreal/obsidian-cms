#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-link-processor-$$"

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
  source "$SCRIPT_DIR/lib/link-resolver.sh"
  source "$SCRIPT_DIR/lib/link-processor.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT"
  mkdir -p "$TEST_VAULT/resources/test"
  mkdir -p "$TEST_VAULT/resources/notes"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # 노트 1: 두 개의 링크
  cat > "$TEST_VAULT/resources/test/main-note.md" << 'EOF'
# Main Note
[[resources/test/sub-note-1|sub-note-1]]
[[resources/notes/sub-note-2|sub-note-2]]
EOF

  # 노트 2: 다른 링크 포함
  cat > "$TEST_VAULT/resources/test/sub-note-1.md" << 'EOF'
# Sub Note 1
[[resources/notes/sub-note-2|sub-note-2]]
EOF

  # 노트 3: 링크 없음
  cat > "$TEST_VAULT/resources/notes/sub-note-2.md" << 'EOF'
# Sub Note 2
No links here.
EOF

  test_pass "Fixtures created"
}

# 테스트 1: 직접 링크 수집
test_collect_direct_links() {
  test_info "Test 1: Collect direct links from file"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/resources/test/main-note.md"
  local links=$(collect_all_linked_files "$file" "$TEST_VAULT")

  local count=$(echo "$links" | grep -c . || true)

  if [ "$count" -eq 2 ]; then
    test_pass "Collected 2 links"
  else
    test_fail "Expected 2 links, found $count"
  fi
}

# 테스트 2: 링크된 파일 경로
test_linked_file_paths() {
  test_info "Test 2: Verify linked file paths"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/resources/test/main-note.md"
  local links=$(collect_all_linked_files "$file" "$TEST_VAULT")

  if echo "$links" | grep -q "sub-note-1.md"; then
    test_pass "Found sub-note-1.md"
  else
    test_fail "sub-note-1.md not found"
  fi
}

# 테스트 3: 중복 제거
test_duplicate_removal() {
  test_info "Test 3: Remove duplicate linked files"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/resources/test/main-note.md"
  local links=$(collect_all_linked_files "$file" "$TEST_VAULT")

  # sub-note-2는 main-note와 sub-note-1에서 모두 참조되지만
  # 목록에는 한 번만 나타나야 함
  local count=$(echo "$links" | grep "sub-note-2" | wc -l)

  if [ "$count" -eq 1 ]; then
    test_pass "Duplicates removed"
  else
    test_fail "Duplicates not removed (found $count instances)"
  fi
}

# 테스트 4: 링크 없는 파일
test_no_links() {
  test_info "Test 4: File without links"
  TESTS_RUN=$((TESTS_RUN + 1))

  local file="$TEST_VAULT/resources/notes/sub-note-2.md"
  local links=$(collect_all_linked_files "$file" "$TEST_VAULT")

  if [ -z "$links" ]; then
    test_pass "No links returned for file without links"
  else
    test_fail "Unexpectedly found links: $links"
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
  echo "Link Processor Test Results"
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
  echo "TDD: Link Processor Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_collect_direct_links
  test_linked_file_paths
  test_duplicate_removal
  test_no_links

  cleanup
  report_results
}

main "$@"
