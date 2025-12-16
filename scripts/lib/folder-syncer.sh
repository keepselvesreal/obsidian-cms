#!/bin/bash

# 폴더 동기화 모듈 (재귀적)
# 사용: sync_folder "source_folder" "dest_folder" [dry_run]

sync_folder() {
  local source="$1"
  local dest="$2"
  local dry_run="${3:-false}"

  if [ ! -d "$source" ]; then
    return 1
  fi

  # 대상 디렉토리 생성
  mkdir -p "$dest"

  if [ "$dry_run" = "true" ]; then
    return 0
  fi

  # rsync로 폴더 동기화 (제외 패턴 적용)
  if rsync -av --delete \
      --exclude='.obsidian' \
      --exclude='.git' \
      --exclude='.DS_Store' \
      --exclude='Thumbs.db' \
      "$source/" "$dest/"; then
    return 0
  else
    return 1
  fi
}
