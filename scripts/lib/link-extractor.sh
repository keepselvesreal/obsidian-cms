#!/bin/bash

# Obsidian 링크 추출 모듈
# 형식: [[path|display-text]] 또는 [[path]]
# 사용: extract_obsidian_links "file.md"

extract_obsidian_links() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # Obsidian 링크 추출: [[...]]
  # 형식: [[path]] 또는 [[path|text]]
  grep -oP '\[\[\K[^\]]+(?=\]\])' "$file" 2>/dev/null || true
}
