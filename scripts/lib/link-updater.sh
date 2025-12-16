#!/bin/bash

# 파일의 Obsidian 링크와 이미지를 public 경로로 업데이트하는 모듈
# 입력: 파일 경로, vault 경로, public 폴더 경로
# 처리:
#   - [[original/path|text]] → [[public/path|text]]
#   - ![[image.png]] → ![[public/attachments/image.png]]
# 사용: update_links_in_file "/path/to/file.md" "/path/to/vault" "/path/to/public"

update_links_in_file() {
  local file="$1"
  local vault="$2"
  local public_dir="$3"

  # 1. 파일 존재 확인
  if [ ! -f "$file" ]; then
    echo "ERROR: File does not exist: $file" >&2
    return 1
  fi

  # 2. vault, public_dir 경로 확인
  if [ ! -d "$vault" ]; then
    echo "ERROR: Vault directory does not exist: $vault" >&2
    return 1
  fi

  if [ ! -d "$public_dir" ]; then
    echo "ERROR: Public directory does not exist: $public_dir" >&2
    return 1
  fi

  # 3. 파일에서 모든 Obsidian 링크 추출
  # 형식: [[path|text]] 또는 [[path]]
  local links=$(extract_obsidian_links "$file" 2>/dev/null || true)

  # 링크가 없으면 그냥 반환
  if [ -z "$links" ]; then
    return 0
  fi

  # 4. 각 링크별로 처리 (process substitution으로 subshell 회피)
  while IFS= read -r link; do
    if [ -z "$link" ]; then
      continue
    fi

    # 링크에서 경로 추출 ([[path|text]] → path)
    local path="${link%%|*}"

    # 파일명만 추출 (경로의 마지막 부분)
    local filename=$(basename "$path")

    # .md 확장자 제거 (정규화)
    local normalized_filename="${filename%.md}"

    # find_in_public으로 public에서 검색
    if public_relative_path=$(find_in_public "$normalized_filename" "$public_dir" 2>/dev/null); then
      # 검색 성공: [[public/...]] 형식으로 변환

      # display text 추출 (|이후 있으면)
      local display_text=""
      if [[ "$link" == *"|"* ]]; then
        display_text="|${link##*|}"
      fi

      # 원본 링크와 새 링크 생성
      local old_link="[[${link}]]"
      local new_link="[[$public_relative_path$display_text]]"

      # perl로 in-place 치환 (구분자를 #로 사용, sed의 복잡한 이스케이프 회피)
      perl -i -pe "s#\Q$old_link\E#$new_link#g" "$file"
    fi
  done <<< "$links"

  # 5. 이미지 링크 업데이트 (![[image.png]] → ![[public/attachments/image.png]])
  # 패턴: ![[filename.ext]] 형식의 이미지 링크
  local image_links=$(grep -oP '!\[\[\K[^\]]+(?=\]\])' "$file" 2>/dev/null || true)

  if [ -n "$image_links" ]; then
    echo "$image_links" | while IFS= read -r image_link; do
      if [ -z "$image_link" ]; then
        continue
      fi

      # 이미지 파일명 추출 (경로가 있으면 파일명만)
      local image_filename=$(basename "$image_link")

      # 원본 이미지 링크와 새 링크 생성
      local old_image_link="![[${image_link}]]"
      local new_image_link="![[public/attachments/$image_filename]]"

      # perl로 in-place 치환
      perl -i -pe "s#\Q$old_image_link\E#$new_image_link#g" "$file"
    done
  fi

  return 0
}
