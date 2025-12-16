#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-file-$$"
TEST_PUBLIC="/tmp/test-public-file-$$"

# 스크립트 디렉토리 (라이브러리 로드용)
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
  source "$SCRIPT_DIR/lib/obsidian-image-extractor.sh"
  source "$SCRIPT_DIR/lib/image-copier.sh"
  source "$SCRIPT_DIR/lib/image-path-converter.sh"
  source "$SCRIPT_DIR/lib/file-syncer.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT" "$TEST_PUBLIC"
  mkdir -p "$TEST_VAULT/resources/attachments"
  mkdir -p "$TEST_VAULT/areas"
  mkdir -p "$TEST_PUBLIC/attachments"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # 픽스처 1: Obsidian 이미지 포함
  cat > "$TEST_VAULT/resources/note-with-image.md" << 'EOF'
# Test Note

This note has an image.

![[test-image.png]]

More content here.
EOF

  # 픽스처 2: 이미지 없음
  cat > "$TEST_VAULT/areas/note-without-image.md" << 'EOF'
# Test Note 2

No images in this note.
EOF

  # 더미 이미지
  echo "fake image data" > "$TEST_VAULT/resources/attachments/test-image.png"

  test_pass "Fixtures created"
}

# 테스트 1: Obsidian 이미지 감지 및 attachments 복사
test_obsidian_image_copy() {
  test_info "Test 1: Detect and copy Obsidian image to attachments"
  TESTS_RUN=$((TESTS_RUN + 1))

  local source_file="$TEST_VAULT/resources/note-with-image.md"
  local dest_attachments="$TEST_PUBLIC/attachments"

  # 이미지 감지
  local images=$(extract_obsidian_images "$source_file")

  if [ -n "$images" ]; then
    # 이미지 복사
    if copy_multiple_images "$images" "$TEST_VAULT/resources/attachments" "$dest_attachments"; then
      if [ -f "$dest_attachments/test-image.png" ]; then
        test_pass "Obsidian image copied to public/attachments"
      else
        test_fail "Image file not found in attachments"
      fi
    else
      test_fail "Image copy failed"
    fi
  else
    test_fail "Obsidian image not detected"
  fi
}

# 테스트 2: Obsidian 형식 유지 확인
test_obsidian_format_preserved() {
  test_info "Test 2: Obsidian image format preserved"
  TESTS_RUN=$((TESTS_RUN + 1))

  local source_file="$TEST_VAULT/resources/note-with-image.md"
  local dest_file="$TEST_PUBLIC/note-with-image.md"

  # 파일 복사
  sync_file "$source_file" "$dest_file" "false"

  # Obsidian 형식 유지 확인
  local obsidian_format=$(grep -oP '!\[\[\K[^]]+(?=\]\])' "$dest_file" 2>/dev/null || true)

  if [ "$obsidian_format" = "test-image.png" ]; then
    test_pass "Obsidian image format preserved (![[...]])"
  else
    test_fail "Obsidian image format not preserved"
  fi
}

# 테스트 3: 첫 경로 세그먼트 제거
test_path_segment_removal() {
  test_info "Test 3: Remove first path segment (resources/)"
  TESTS_RUN=$((TESTS_RUN + 1))

  local input="resources/book-summaries/note.md"
  local expected="book-summaries/note.md"
  local output="${input#*/}"

  if [ "$output" = "$expected" ]; then
    test_pass "First path segment removed correctly"
  else
    test_fail "Path removal failed (expected: $expected, got: $output)"
  fi
}

# 테스트 4: 이미지 없는 파일도 정상 동기화
test_file_without_image_sync() {
  test_info "Test 4: Sync file without images"
  TESTS_RUN=$((TESTS_RUN + 1))

  local source_file="$TEST_VAULT/areas/note-without-image.md"
  local dest_file="$TEST_PUBLIC/note-without-image.md"

  if sync_file "$source_file" "$dest_file" "false"; then
    if [ -f "$dest_file" ]; then
      test_pass "File without images synced successfully"
    else
      test_fail "File not found after sync"
    fi
  else
    test_fail "File sync failed"
  fi
}

# 정리
cleanup() {
  test_info "Cleaning up test environment..."
  rm -rf "$TEST_VAULT" "$TEST_PUBLIC"
  test_pass "Test environment cleaned up"
}

# 결과 리포트
report_results() {
  echo ""
  echo "================================"
  echo "File Sync Test Results"
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
  echo "TDD: File Sync Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_obsidian_image_copy
  test_obsidian_format_preserved
  test_path_segment_removal
  test_file_without_image_sync

  cleanup
  report_results
}

main "$@"
