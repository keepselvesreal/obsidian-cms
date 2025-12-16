#!/bin/bash

# 이미지 경로를 변환하는 모듈
# Obsidian 형식 (![[image.png]]) -> 마크다운 형식 (![](/attachments/image.png))
# vault 루트 기준 절대 경로를 사용하여 옵시디언에서 제대로 인식되도록 함
# 사용: convert_obsidian_to_markdown "file.md"

convert_obsidian_to_markdown() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # ![[image.png]] -> ![](/attachments/image.png)
  # /attachments는 vault 루트 기준 절대 경로 (옵시디언이 정확히 인식)
  sed -i 's/!\[\[\([^]]*\)\]\]/![](\/attachments\/\1)/g' "$file"

  return 0
}
