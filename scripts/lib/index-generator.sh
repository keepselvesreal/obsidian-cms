#!/bin/bash

# ============================================================
# Index Generator Library
# 폴더에 index.md를 자동으로 생성합니다
# ============================================================

# ============================================================
# 함수: 주어진 폴더에 index.md 생성
# 입력: $1 = 폴더 경로 (절대 경로)
# 처리: index.md가 없으면 생성, 있으면 스킵
# ============================================================
generate_folder_index() {
  local folder="$1"
  local index_file="$folder/index.md"

  log_debug "generate_folder_index: $folder"

  # 이미 index.md가 있으면 생성하지 않음
  if [ -f "$index_file" ]; then
    log_debug "Index already exists: $index_file"
    return 0
  fi

  # 폴더명 추출
  local folder_name
  folder_name=$(basename "$folder")

  # 제목: 폴더명에서 - 를 공백으로 치환
  local title="${folder_name//-/ }"

  # cover 이미지 찾기 (cover.png 또는 cover.*)
  local cover_image=""
  if [ -f "$folder/cover.png" ]; then
    cover_image="cover.png"
  fi

  # index.md 생성
  {
    echo "---"
    echo "title: \"$title\""
    echo "---"
    echo ""

    if [ -n "$cover_image" ]; then
      echo "![cover](./$cover_image)"
      echo ""
    fi
  } > "$index_file"

  log_success "  ✓ Created index: $(basename "$folder")/index.md"

  return 0
}

# ============================================================
# 함수: 주어진 폴더에 index.md 생성 (동기 폴더용)
# 입력: $1 = CMS 대상 폴더 경로 (절대 경로)
# ============================================================
create_index_if_needed() {
  local dest_folder="$1"

  # 폴더 존재 확인
  if [ ! -d "$dest_folder" ]; then
    log_debug "Destination folder does not exist: $dest_folder"
    return 0
  fi

  generate_folder_index "$dest_folder"
  return 0
}
