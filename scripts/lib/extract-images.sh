#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# 파일에서 이미지 경로 추출
extract_images_from_file() {
  local md_file="$1"

  if [ ! -f "$md_file" ]; then
    log_error "File not found: $md_file"
    return 1
  fi

  # ![alt](../../../resources/attachments/image.png) 형식의 이미지 경로 추출
  # 정규식: !\[.*?\]\(([^)]*attachments[^)]*)\)
  grep -oP '!\[.*?\]\(\K[^)]*attachments[^)]*' "$md_file" 2>/dev/null | sort | uniq
}

# 상대경로 → 절대경로 변환
get_absolute_path() {
  local rel_path="$1"
  local base_dir="$2"

  # ../../../resources/attachments/image.png 같은 상대경로를 절대경로로 변환
  # base_dir에서 상대경로로 이동해서 절대경로 얻기
  cd "$base_dir" 2>/dev/null || return 1
  echo "$(cd "$(dirname "$rel_path")" && pwd)/$(basename "$rel_path")"
  cd - > /dev/null
}

# 이미지 파일명만 추출
get_filename() {
  basename "$1"
}
