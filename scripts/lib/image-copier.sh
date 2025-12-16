#!/bin/bash

# 이미지를 public/attachments로 복사하는 모듈
# 사용: copy_image_to_attachments "image.png" "/path/to/source" "/path/to/dest/attachments"

copy_image_to_attachments() {
  local image_name="$1"
  local source_dir="$2"
  local dest_attachments="$3"

  if [ -z "$image_name" ] || [ -z "$source_dir" ] || [ -z "$dest_attachments" ]; then
    return 1
  fi

  local source_image="$source_dir/$image_name"
  local dest_image="$dest_attachments/$image_name"

  # 소스 이미지 확인
  if [ ! -f "$source_image" ]; then
    return 1
  fi

  # 대상 디렉토리 생성
  mkdir -p "$dest_attachments"

  # 이미지 복사
  if cp "$source_image" "$dest_image"; then
    return 0
  else
    return 1
  fi
}

# 여러 이미지를 한번에 복사
# 사용: copy_multiple_images "images_list" "/path/to/source" "/path/to/dest/attachments"
copy_multiple_images() {
  local images_list="$1"
  local source_dir="$2"
  local dest_attachments="$3"
  local success_count=0

  mkdir -p "$dest_attachments"

  while IFS= read -r image_name; do
    if [ -n "$image_name" ]; then
      if copy_image_to_attachments "$image_name" "$source_dir" "$dest_attachments"; then
        success_count=$((success_count + 1))
      fi
    fi
  done <<< "$images_list"

  return 0
}
