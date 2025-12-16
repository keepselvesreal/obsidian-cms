#!/bin/bash

# Public 폴더에서 파일명으로 검색하는 모듈
# 입력: 파일명 (예: "test-image-copy" 또는 "test-image-copy.md")
# 입력: public 폴더 경로
# 출력: public 기준 상대 경로 (예: "public/test/test-image-copy")
# 사용: find_in_public "test-image-copy" "/path/to/public"

find_in_public() {
  local filename="$1"      # 검색할 파일명
  local public_dir="$2"    # public 폴더 경로

  # 1. public 폴더 존재 확인
  if [ ! -d "$public_dir" ]; then
    echo "ERROR: Public folder does not exist: $public_dir" >&2
    return 1
  fi

  # 2. 파일명이 비어있는지 확인
  if [ -z "$filename" ]; then
    echo "ERROR: Filename is empty" >&2
    return 1
  fi

  # 3. .md 확장자 정규화 (있으면 제거)
  local normalized_filename="${filename%.md}"

  # 4. public 폴더에서 파일 검색
  # find로 정확한 파일명 검색 (*.md 확장자 포함)
  local found_file=$(find "$public_dir" -type f -name "${normalized_filename}.md" 2>/dev/null | head -n 1)

  # 5. 파일을 찾지 못한 경우
  if [ -z "$found_file" ]; then
    return 1
  fi

  # 6. public_dir 상대 경로로 변환 (상대 경로 계산)
  # 예: /path/to/public/test/test-image-copy.md
  #     → public/test/test-image-copy
  local relative_path="${found_file#${public_dir}/}"  # public 이후 상대 경로
  relative_path="${relative_path%.md}"                # .md 확장자 제거
  relative_path="public/$relative_path"               # public 접두사 추가

  echo "$relative_path"
  return 0
}
