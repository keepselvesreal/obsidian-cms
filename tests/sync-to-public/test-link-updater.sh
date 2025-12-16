#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-link-updater-$$"

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
  source "$SCRIPT_DIR/lib/logger.sh"
  source "$SCRIPT_DIR/lib/link-extractor.sh"
  source "$SCRIPT_DIR/lib/find-in-public.sh"
  source "$SCRIPT_DIR/lib/link-updater.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT"
  mkdir -p "$TEST_VAULT/public/test"
  mkdir -p "$TEST_VAULT/public/book-summaries"
  mkdir -p "$TEST_VAULT/resources/test"
  mkdir -p "$TEST_VAULT/areas/books"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # public에 이미 존재하는 파일
  cat > "$TEST_VAULT/public/test/existing-note.md" << 'EOF'
# Existing Note
EOF

  # public에 없는 원본 파일
  cat > "$TEST_VAULT/resources/test/linked-note.md" << 'EOF'
# Linked Note
EOF

  cat > "$TEST_VAULT/areas/books/summary.md" << 'EOF'
# Book Summary
EOF

  # public으로 복사될 파일 (링크 포함)
  cat > "$TEST_VAULT/public/test/notes-with-links.md" << 'EOF'
# Notes with Links

## 기존 링크들
[[resources/test/linked-note|linked-note]]
[[areas/books/summary|summary]]
[[resources/test/existing-note.md|existing-note]]

일반 텍스트
EOF

  test_pass "Fixtures created"
}

# 테스트 1: 이미 public에 있는 링크 업데이트
test_update_existing_public_link() {
  test_info "Test 1: Update link that already exists in public"
  TESTS_RUN=$((TESTS_RUN + 1))

  # 먼저 existing-note를 링크로 포함한 파일 생성
  local test_file="$TEST_VAULT/public/test/test1.md"
  cat > "$test_file" << 'EOF'
[[resources/test/existing-note|existing-note]]
EOF

  # 링크 업데이트 실행
  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    # 업데이트된 내용 확인
    if grep -q "\\[\\[public/test/existing-note|existing-note\\]\\]" "$test_file"; then
      test_pass "Existing public link updated correctly"
    else
      test_fail "Link not updated correctly (content: $(cat "$test_file"))"
    fi
  else
    test_fail "Failed to update links"
  fi
}

# 테스트 2: display text가 없는 링크 업데이트
test_update_link_without_display_text() {
  test_info "Test 2: Update link without display text"
  TESTS_RUN=$((TESTS_RUN + 1))

  local test_file="$TEST_VAULT/public/test/test2.md"
  cat > "$test_file" << 'EOF'
[[resources/test/existing-note]]
EOF

  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    if grep -q "\\[\\[public/test/existing-note\\]\\]" "$test_file"; then
      test_pass "Link without display text updated correctly"
    else
      test_fail "Link not updated correctly"
    fi
  else
    test_fail "Failed to update links"
  fi
}

# 테스트 3: 여러 개의 링크 모두 업데이트
test_update_multiple_links() {
  test_info "Test 3: Update multiple links in file"
  TESTS_RUN=$((TESTS_RUN + 1))

  local test_file="$TEST_VAULT/public/test/test3.md"
  cat > "$test_file" << 'EOF'
Link 1: [[resources/test/existing-note|note1]]
Link 2: [[resources/test/existing-note]]
More text
EOF

  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    local link_count=$(grep -c "\\[\\[public/test/existing-note" "$test_file" || echo "0")
    if [ "$link_count" -eq 2 ]; then
      test_pass "Multiple links updated correctly"
    else
      test_fail "Not all links updated (count: $link_count)"
    fi
  else
    test_fail "Failed to update links"
  fi
}

# 테스트 4: .md 확장자 정규화
test_update_link_with_md_extension() {
  test_info "Test 4: Update link with .md extension"
  TESTS_RUN=$((TESTS_RUN + 1))

  local test_file="$TEST_VAULT/public/test/test4.md"
  cat > "$test_file" << 'EOF'
[[resources/test/existing-note.md|note]]
EOF

  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    if grep -q "\\[\\[public/test/existing-note|note\\]\\]" "$test_file"; then
      test_pass "Link with .md extension updated correctly"
    else
      test_fail "Link not updated correctly"
    fi
  else
    test_fail "Failed to update links"
  fi
}

# 테스트 5: 링크가 없는 파일은 그대로 유지
test_file_without_links() {
  test_info "Test 5: File without links should remain unchanged"
  TESTS_RUN=$((TESTS_RUN + 1))

  local test_file="$TEST_VAULT/public/test/test5.md"
  cat > "$test_file" << 'EOF'
# Simple Note
No links here
EOF

  local original_content=$(cat "$test_file")

  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    local updated_content=$(cat "$test_file")
    if [ "$original_content" = "$updated_content" ]; then
      test_pass "File without links remained unchanged"
    else
      test_fail "File was modified unnecessarily"
    fi
  else
    test_fail "Failed to process file"
  fi
}

# 테스트 6: 이미지 링크 업데이트
test_update_image_links() {
  test_info "Test 6: Update image links"
  TESTS_RUN=$((TESTS_RUN + 1))

  local test_file="$TEST_VAULT/public/test/test6.md"
  cat > "$test_file" << 'EOF'
# File with images
![[Pasted image 20251216152427.png]]
EOF

  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    if grep -q "!\\[\\[public/attachments/Pasted image 20251216152427.png\\]\\]" "$test_file"; then
      test_pass "Image link updated to public/attachments path"
    else
      test_fail "Image link not updated correctly (content: $(cat "$test_file"))"
    fi
  else
    test_fail "Failed to update image links"
  fi
}

# 테스트 7: 이미지 링크와 문서 링크 함께 업데이트
test_update_mixed_links() {
  test_info "Test 7: Update mixed document and image links"
  TESTS_RUN=$((TESTS_RUN + 1))

  local test_file="$TEST_VAULT/public/test/test7.md"
  cat > "$test_file" << 'EOF'
Document link: [[resources/test/existing-note|note]]
Image link: ![[screenshot.png]]
EOF

  if update_links_in_file "$test_file" "$TEST_VAULT" "$TEST_VAULT/public" 2>/dev/null; then
    local doc_link_ok=false
    local img_link_ok=false

    if grep -q "\\[\\[public/test/existing-note|note\\]\\]" "$test_file"; then
      doc_link_ok=true
    fi

    if grep -q "!\\[\\[public/attachments/screenshot.png\\]\\]" "$test_file"; then
      img_link_ok=true
    fi

    if [ "$doc_link_ok" = true ] && [ "$img_link_ok" = true ]; then
      test_pass "Both document and image links updated correctly"
    else
      test_fail "Mixed links not updated correctly (doc_ok=$doc_link_ok, img_ok=$img_link_ok)"
    fi
  else
    test_fail "Failed to update mixed links"
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
  echo "Link Updater Test Results"
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
  echo "TDD: Link Updater Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_update_existing_public_link
  test_update_link_without_display_text
  test_update_multiple_links
  test_update_link_with_md_extension
  test_file_without_links
  test_update_image_links
  test_update_mixed_links

  cleanup
  report_results
}

main "$@"
