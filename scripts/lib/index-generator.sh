#!/bin/bash

set -euo pipefail

# 주어진 폴더에 대해 index.md를 생성하는 함수
# 인자: $1 = 폴더 경로 (절대 경로)
generate_folder_index() {
  local folder="$1"
  local index_file="$folder/index.md"

  # 이미 index.md가 있으면 생성하지 않음
  if [ -f "$index_file" ]; then
    return 0
  fi

  # .md 파일 목록 (index.md 제외)
  local md_files=()
  while IFS= read -r file; do
    if [ "$(basename "$file")" != "index.md" ]; then
      md_files+=("$file")
    fi
  done < <(find "$folder" -maxdepth 1 -type f -name "*.md" | sort)

  # 마크다운 파일이 없으면 생성하지 않음
  if [ ${#md_files[@]} -eq 0 ]; then
    return 0
  fi

  # 폴더명 추출
  local folder_name=$(basename "$folder")

  # 제목: 폴더명에서 - 제거 (소문자 유지)
  local title="${folder_name//-/ }"

  # cover 이미지 찾기
  local cover_image=""
  if ls "$folder"/cover.* >/dev/null 2>&1; then
    cover_image=$(ls "$folder"/cover.* | head -1)
    cover_image=$(basename "$cover_image")
  fi

  # index.md 생성
  {
    echo "---"
    echo "title: \"$title\""
    echo "---"
    echo ""

    if [ -n "$cover_image" ]; then
      echo "![cover](./$(basename "$cover_image"))"
      echo ""
    fi
  } > "$index_file"
}

# 모든 하위 폴더에 대해 index 생성
generate_all_folder_indexes() {
  local root_folder="$1"

  if [ ! -d "$root_folder" ]; then
    return 0
  fi

  # 모든 하위 폴더를 find로 한 번에 찾아서 처리
  while IFS= read -r folder; do
    generate_folder_index "$folder"
  done < <(find "$root_folder" -type d | sort)
}
