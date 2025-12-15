#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# 외부 경로 감지 (public 폴더 밖의 링크만)
# [[areas/...]], [[resources/...]], [[../...]] 등 외부 폴더를 감지
has_external_paths() {
  local md_file="$1"

  # [[..]] 또는 [[areas/]] 또는 [[resources/]] 등 외부 폴더만 감지
  if grep -qP '\[\[(\.\./|areas/|resources/)' "$md_file" 2>/dev/null; then
    return 0  # 외부 경로 있음
  fi
  return 1  # 외부 경로 없음
}

# 이미지 파일명만 복사 (Obsidian 형식 `![[filename.png]]`에서)
copy_image_if_missing() {
  local img_filename="$1"
  local public_dir="${2:-.}"

  # public_dir을 절대경로로 정규화
  if [[ "$public_dir" != /* ]]; then
    public_dir="$(cd "$public_dir" 2>/dev/null && pwd)" || public_dir="."
  fi

  # 절대경로 구성 (public 폴더의 부모 디렉토리에서 resources/attachments)
  local parent_dir="$(dirname "$public_dir")"
  local source="$parent_dir/resources/attachments/$img_filename"
  local dest="$public_dir/attachments/$img_filename"

  # public/attachments 폴더 생성
  mkdir -p "$(dirname "$dest")"

  # 파일이 이미 dest에 있는지 확인
  if [ -f "$dest" ]; then
    log_info "Already exists: $img_filename"
    return 0
  fi

  # source 파일이 있는지 확인
  if [ ! -f "$source" ]; then
    log_error "Source not found: $source"
    return 1
  fi

  # 파일 복사
  if cp "$source" "$dest" 2>/dev/null; then
    log_success "Copied: $img_filename"
    return 0
  else
    log_error "Failed to copy: $img_filename"
    return 1
  fi
}
