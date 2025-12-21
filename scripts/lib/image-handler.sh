#!/bin/bash

# ============================================================
# Image Handler Library
# 마크다운 이미지 추출 및 복사를 관리합니다
# ============================================================

# ============================================================
# 함수: 마크다운 형식 이미지 추출 및 복사
# 입력: $1 = 마크다운 파일, $2 = DRY_RUN (선택사항)
# 처리: ![alt](path) 형식의 이미지
# ============================================================
sync_markdown_images() {
  local file="$1"
  local dry_run="${2:-false}"

  log_debug "sync_markdown_images: processing $file"

  # 이미지 링크 추출: ![alt](path) 형식
  local images
  images=$(grep -oP '!\[.*?\]\(\K[^)]+' "$file" 2>/dev/null || true)

  if [ -z "$images" ]; then
    log_debug "sync_markdown_images: no markdown images found"
    return 0
  fi

  log_info "Found markdown images, copying to attachments..."

  while IFS= read -r img_path; do
    [ -z "$img_path" ] && continue

    # 절대 경로로 변환 (상대 경로 기준: 파일의 디렉토리)
    local file_dir
    file_dir=$(dirname "$file")

    local img_abs_path
    img_abs_path=$(cd "$file_dir" && cd "$(dirname "$img_path")" && pwd)/$(basename "$img_path")

    # 파일 존재 확인
    if [ ! -f "$img_abs_path" ]; then
      log_warning "Image not found: $img_abs_path"
      continue
    fi

    local img_filename
    img_filename=$(basename "$img_abs_path")

    local dest_path="$CONTENT_DIR/$ATTACHMENTS_DEST/$img_filename"

    if [ "$dry_run" = false ]; then
      mkdir -p "$CONTENT_DIR/$ATTACHMENTS_DEST"
      cp "$img_abs_path" "$dest_path"
      log_success "  ✓ Copied: $img_filename"
    else
      log_info "[DRY-RUN] Would copy image: $img_filename"
    fi
  done <<< "$images"

  return 0
}

# ============================================================
# 함수: Obsidian 임베드 이미지 추출 및 복사
# 입력: $1 = 마크다운 파일, $2 = DRY_RUN (선택사항)
# 처리: ![[image.png]] 또는 ![[image.png|width]] 형식
# ============================================================
sync_obsidian_embed_images() {
  local file="$1"
  local dry_run="${2:-false}"

  log_debug "sync_obsidian_embed_images: processing $file"

  # Obsidian 임베드 이미지 링크 추출: ![[image.png]] 또는 ![[image.png|width]] 형식
  local embed_images
  embed_images=$(grep -oP '!\[\[\K[^\]|]+' "$file" 2>/dev/null || true)

  if [ -z "$embed_images" ]; then
    log_debug "sync_obsidian_embed_images: no embed images found"
    return 0
  fi

  log_info "Found Obsidian embed images, searching and copying..."

  while IFS= read -r img_name; do
    [ -z "$img_name" ] && continue

    local img_abs_path=""

    # 1. 현재 마크다운 파일 디렉토리에서 찾기
    local file_dir
    file_dir=$(dirname "$file")
    if [ -f "$file_dir/$img_name" ]; then
      img_abs_path="$file_dir/$img_name"
    fi

    # 2. attachments 폴더에서 찾기
    if [ -z "$img_abs_path" ] && [ -f "$OBSIDIAN_VAULT/attachments/$img_name" ]; then
      img_abs_path="$OBSIDIAN_VAULT/attachments/$img_name"
    fi

    # 파일 존재 확인
    if [ ! -f "$img_abs_path" ]; then
      log_warning "Obsidian embed image not found: $img_name"
      continue
    fi

    local img_filename
    img_filename=$(basename "$img_abs_path")

    local dest_path="$CONTENT_DIR/$ATTACHMENTS_DEST/$img_filename"

    if [ "$dry_run" = false ]; then
      mkdir -p "$CONTENT_DIR/$ATTACHMENTS_DEST"
      cp "$img_abs_path" "$dest_path"
      log_success "  ✓ Copied: $img_filename"
    else
      log_info "[DRY-RUN] Would copy image: $img_filename"
    fi
  done <<< "$embed_images"

  return 0
}

# ============================================================
# 함수: 모든 이미지 동기화
# 입력: $1 = 마크다운 파일, $2 = DRY_RUN (선택사항)
# ============================================================
sync_all_images() {
  local file="$1"
  local dry_run="${2:-false}"

  log_section "Syncing Images"

  sync_markdown_images "$file" "$dry_run"
  sync_obsidian_embed_images "$file" "$dry_run"

  return 0
}
