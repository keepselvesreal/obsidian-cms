#!/bin/bash

# Obsidian 형식 이미지 추출 모듈
# 사용: extract_obsidian_images "file.md"

extract_obsidian_images() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  # Obsidian 형식: ![[filename.png]]
  grep -oP '!\[\[\K[^]]+(?=\]\])' "$file" 2>/dev/null || true
}
