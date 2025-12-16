#!/bin/bash

set -euo pipefail

# 테스트 디렉토리
TEST_VAULT="/tmp/test-vault-folder-$$"
TEST_PUBLIC="/tmp/test-public-folder-$$"

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
  source "$SCRIPT_DIR/lib/folder-syncer.sh"
}

# 테스트 환경 설정
setup() {
  test_info "Setting up test environment..."

  rm -rf "$TEST_VAULT" "$TEST_PUBLIC"
  mkdir -p "$TEST_VAULT/resources/attachments"
  mkdir -p "$TEST_VAULT/resources/test-folder"
  mkdir -p "$TEST_PUBLIC/attachments"

  test_pass "Test environment created"
}

# 픽스처 생성
create_fixtures() {
  test_info "Creating test fixtures..."

  # 픽스처 1: 폴더 내 이미지 포함 파일
  cat > "$TEST_VAULT/resources/test-folder/note-with-image.md" << 'EOF'
# Folder Note 1

![[folder-image.png]]

Content here.
EOF

  # 픽스처 2: 폴더 내 이미지 없는 파일
  cat > "$TEST_VAULT/resources/test-folder/note-without-image.md" << 'EOF'
# Folder Note 2

No images.
EOF

  # 픽스처 3: 폴더 내 서브폴더
  mkdir -p "$TEST_VAULT/resources/test-folder/subfolder"
  cat > "$TEST_VAULT/resources/test-folder/subfolder/nested-note.md" << 'EOF'
# Nested Note

![[nested-image.png]]
EOF

  # 더미 이미지
  echo "fake image 1" > "$TEST_VAULT/resources/attachments/folder-image.png"
  echo "fake image 2" > "$TEST_VAULT/resources/attachments/nested-image.png"

  test_pass "Fixtures created"
}

# 테스트 1: 폴더 재귀 동기화
test_folder_recursive_sync() {
  test_info "Test 1: Folder sync with recursive structure"
  TESTS_RUN=$((TESTS_RUN + 1))

  local source_folder="$TEST_VAULT/resources/test-folder"
  local dest_folder="$TEST_PUBLIC/test-folder"

  if sync_folder "$source_folder" "$dest_folder" "false"; then
    local file_count=$(find "$dest_folder" -type f | wc -l)

    if [ "$file_count" -eq 3 ]; then
      test_pass "Folder synced with all files (found $file_count files)"
    else
      test_fail "Folder sync incomplete (expected 3 files, found $file_count)"
    fi
  else
    test_fail "Folder sync failed"
  fi
}

# 테스트 2: 폴더 내 모든 파일의 이미지 추출
test_extract_images_from_folder() {
  test_info "Test 2: Extract images from all files in folder"
  TESTS_RUN=$((TESTS_RUN + 1))

  local note1="$TEST_VAULT/resources/test-folder/note-with-image.md"
  local note2="$TEST_VAULT/resources/test-folder/subfolder/nested-note.md"

  local images1=$(extract_obsidian_images "$note1")
  local images2=$(extract_obsidian_images "$note2")

  if [[ "$images1" == "folder-image.png" ]] && [[ "$images2" == "nested-image.png" ]]; then
    test_pass "Images extracted from all folder files"
  else
    test_fail "Image extraction from folder files failed"
  fi
}

# 테스트 3: 폴더의 이미지들을 attachments로 복사
test_copy_folder_images_to_attachments() {
  test_info "Test 3: Copy all folder images to attachments"
  TESTS_RUN=$((TESTS_RUN + 1))

  local note1="$TEST_VAULT/resources/test-folder/note-with-image.md"
  local note2="$TEST_VAULT/resources/test-folder/subfolder/nested-note.md"
  local dest_attachments="$TEST_PUBLIC/attachments"

  # 각 파일에서 이미지 추출 및 복사
  local images1=$(extract_obsidian_images "$note1")
  local images2=$(extract_obsidian_images "$note2")

  copy_multiple_images "$images1" "$TEST_VAULT/resources/attachments" "$dest_attachments"
  copy_multiple_images "$images2" "$TEST_VAULT/resources/attachments" "$dest_attachments"

  local copied_images=$(find "$dest_attachments" -type f | wc -l)

  if [ "$copied_images" -eq 2 ]; then
    test_pass "All folder images copied to attachments"
  else
    test_fail "Not all images copied (expected 2, found $copied_images)"
  fi
}

# 테스트 4: 첫 경로 세그먼트 제거 (areas/)
test_path_segment_removal_areas() {
  test_info "Test 4: Remove first path segment (areas/)"
  TESTS_RUN=$((TESTS_RUN + 1))

  local input="areas/book-summaries/test-folder"
  local expected="book-summaries/test-folder"
  local output="${input#*/}"

  if [ "$output" = "$expected" ]; then
    test_pass "Areas path segment removed correctly"
  else
    test_fail "Path removal failed (expected: $expected, got: $output)"
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
  echo "Folder Sync Test Results"
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
  echo "TDD: Folder Sync Tests"
  echo "========================================="
  echo ""

  load_libraries
  setup
  create_fixtures

  test_folder_recursive_sync
  test_extract_images_from_folder
  test_copy_folder_images_to_attachments
  test_path_segment_removal_areas

  cleanup
  report_results
}

main "$@"
