#!/bin/bash

# 파일 동기화 모듈
# 사용: sync_file "source_file" "dest_file" [dry_run]

sync_file() {
  local source="$1"
  local dest="$2"
  local dry_run="${3:-false}"

  if [ ! -f "$source" ]; then
    return 1
  fi

  # 대상 디렉토리 생성
  mkdir -p "$(dirname "$dest")"

  if [ "$dry_run" = "true" ]; then
    return 0
  fi

  # 파일 복사
  if cp "$source" "$dest"; then
    return 0
  else
    return 1
  fi
}
