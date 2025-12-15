#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/copy-images.sh"

# 외부 경로 검증 및 변환 (외부 경로가 있으면 오류 발생)
update_image_paths() {
  local md_file="$1"

  if [ ! -f "$md_file" ]; then
    log_error "File not found: $md_file"
    return 1
  fi

  # 외부 경로 감지 (areas/, ../ 등)
  if has_external_paths "$md_file"; then
    log_error "External path detected in: $md_file"
    log_error "Cannot process files with external references (e.g., [[areas/...]], [[../...]])"
    return 1
  fi

  # 1단계: Obsidian 형식 이미지 변환
  # ![[filename.png]] → ![filename](./attachments/filename.png)
  if grep -q '!\[\[[^\]]*\]\]' "$md_file" 2>/dev/null; then
    # Obsidian 형식 이미지 추출 후 변환
    while IFS= read -r obsidian_img; do
      if [ -z "$obsidian_img" ]; then
        continue
      fi

      # 파일명만 추출
      local filename="$obsidian_img"

      # 이미지 복사 시도
      local public_dir="$(dirname "$md_file")"
      if copy_image_if_missing "$filename" "$public_dir"; then
        # Obsidian 형식을 마크다운 형식으로 변환
        sed -i "s|!\\[\\[$filename\\]\\]|![$filename](./attachments/$filename)|g" "$md_file"
      fi
    done < <(grep -oP '!\[\[\K[^]]+(?=\]\])' "$md_file" 2>/dev/null)

    log_success "Converted Obsidian image format: $md_file"
  fi

  # 2단계: 마크다운 경로 수정
  # ../../../resources/attachments/ → ./attachments/
  if sed -i 's|\.\./\.\./\.\./resources/attachments/|./attachments/|g' "$md_file" 2>/dev/null; then
    log_success "Updated image paths: $md_file"
    return 0
  else
    log_error "Failed to update paths in: $md_file"
    return 1
  fi
}
