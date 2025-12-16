#!/bin/bash

# Obsidian 링크를 절대 경로로 변환하는 모듈
# 입력: [[path|text]] 형식의 링크
# 출력: 절대 경로 또는 오류
# 사용: resolve_link "resources/test/test-image-copy|test-image-copy" "/path/to/vault"

resolve_link() {
  local link="$1"      # "resources/test/test-image-copy" 또는 "resources/test/test-image-copy|text"
  local vault="$2"     # Obsidian vault 경로

  # 1. [[path|text]] 형식에서 경로만 추출 (| 이전까지)
  local path="${link%%|*}"

  # 2. 경로가 비어있으면 오류
  if [ -z "$path" ]; then
    echo "ERROR: 링크에 경로가 없습니다: [[$link]]" >&2
    return 1
  fi

  # 3. .md 확장자 추가 (없을 경우)
  local file_path="${path%.md}.md"

  # 4. vault 루트 기준 절대경로
  local absolute_path="$vault/$file_path"

  # 5. 파일 존재 확인
  if [ ! -f "$absolute_path" ]; then
    echo "ERROR: 링크된 파일을 찾을 수 없습니다: $absolute_path" >&2
    return 1
  fi

  echo "$absolute_path"
  return 0
}
