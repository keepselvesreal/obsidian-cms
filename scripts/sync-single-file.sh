#!/bin/bash

# ============================================================
# Sync Single File Script
# 단일 마크다운 파일을 CMS로 동기화합니다.
# ============================================================

set -euo pipefail

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/yaml-parser.sh"
source "$SCRIPT_DIR/lib/link-remover.sh"
source "$SCRIPT_DIR/config.sh"

# ============================================================
# 함수: 파일을 content로 복사
# 입력: $1 = 원본 파일
#       $2 = Destination 폴더 (content 내 상대 경로)
#       $3 = DRY_RUN (true/false, 선택사항)
# ============================================================
copy_file() {
  local source="$1"
  local dest_folder="$2"
  local dry_run="${3:-$DRY_RUN}"

  local filename
  filename=$(basename "$source")

  local dest_dir="$CONTENT_DIR/$dest_folder"
  local dest_file="$dest_dir/$filename"

  if [ "$dry_run" = false ]; then
    mkdir -p "$dest_dir"
    cp "$source" "$dest_file"
    log_success "Copied: $filename → $dest_folder/"
  else
    log_info "[DRY-RUN] Would copy: $filename → $dest_folder/"
  fi
}

# ============================================================
# 함수: Obsidian 임베드 이미지 추출 및 복사
# 입력: $1 = 마크다운 파일
#       $2 = DRY_RUN
# ============================================================
sync_obsidian_embed_images() {
  local file="$1"
  local dry_run="${2:-$DRY_RUN}"

  # Obsidian 임베드 이미지 링크 추출: ![[image.png]] 또는 ![[image.png|width]] 형식
  local embed_images
  embed_images=$(grep -oP '!\[\[\K[^\]|]+' "$file" 2>/dev/null || true)

  if [ -z "$embed_images" ]; then
    return 0
  fi

  log_info "Found Obsidian embed images, searching and copying..."

  while IFS= read -r img_name; do
    [ -z "$img_name" ] && continue

    # 이미지 파일 찾기 (Vault 내에서)
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

    # 3. 파일 이름으로 Vault 내 검색 (선택사항: 성능을 위해 비활성화 가능)
    # if [ -z "$img_abs_path" ]; then
    #   img_abs_path=$(find "$OBSIDIAN_VAULT" -name "$img_name" -type f 2>/dev/null | head -1)
    # fi

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
}

# ============================================================
# 함수: 이미지 추출 및 복사
# 입력: $1 = 마크다운 파일
#       $2 = DRY_RUN
# ============================================================
sync_images() {
  local file="$1"
  local dry_run="${2:-$DRY_RUN}"

  # 이미지 링크 추출: ![alt](path) 형식
  local images
  images=$(grep -oP '!\[.*?\]\(\K[^)]+' "$file" 2>/dev/null || true)

  if [ -z "$images" ]; then
    return 0
  fi

  log_info "Found images, copying to attachments..."

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
}

# ============================================================
# 함수: references 필드의 파일들 동기화
# 입력: $1 = 마크다운 파일 (posts 폴더)
#       $2 = DRY_RUN
# ============================================================
sync_referenced_files() {
  local file="$1"
  local dry_run="${2:-$DRY_RUN}"

  # references 필드 추출
  local references
  references=$(extract_references "$file") || return 0  # references가 없으면 그냥 진행

  if [ -z "$references" ]; then
    log_info "No references field found"
    return 0
  fi

  log_info "Processing references..."

  while IFS= read -r reference; do
    [ -z "$reference" ] && continue

    # [[...]] 형식 처리
    local normalized_ref
    normalized_ref=$(extract_path_from_reference "$reference")

    local file_path
    if file_path=$(resolve_reference_to_file "$normalized_ref" "$OBSIDIAN_VAULT"); then
      # normalized_ref는 "books/path" 형식
      local source_type="${normalized_ref%%/*}"  # "books" 또는 "web-contents"

      # 대응하는 destination 폴더 결정
      local dest_folder=""
      case "$source_type" in
        books)
          dest_folder="$BOOKS_DEST"
          ;;
        web-contents)
          dest_folder="$WEB_CONTENTS_DEST"
          ;;
        *)
          log_warning "Unknown reference type: $source_type"
          continue
          ;;
      esac

      # 파일 또는 폴더 여부 확인
      if [ -f "$file_path" ]; then
        # 파일: 이 파일만 동기화 (폴더 구조 유지)
        if [ "$dry_run" = false ]; then
          # 파일 복사 전 링크 제거
          local temp_file
          temp_file=$(mktemp)
          cp "$file_path" "$temp_file"
          remove_obsidian_links "$temp_file"

          # 폴더 구조 유지: file_path에서 resources 이후 부분 추출
          # /vault/resources/books/the-art-of-unit-testing/좋은-...md
          # → the-art-of-unit-testing/좋은-...md
          local relative_path="${file_path#*resources/}"
          # 첫 번째 세그먼트 제거 (books/web-contents 등)
          relative_path="${relative_path#*/}"
          local dest_file="$CONTENT_DIR/$dest_folder/$relative_path"
          mkdir -p "$(dirname "$dest_file")"
          mv "$temp_file" "$dest_file"
          log_success "  ✓ Synced: $(basename "$file_path")"
        else
          log_info "[DRY-RUN] Would sync file: $(basename "$file_path")"
        fi

      elif [ -d "$file_path" ]; then
        # 폴더: 내부의 모든 .md 파일 동기화 (폴더 구조 유지)
        log_info "Processing folder: $reference"

        # normalized_ref에서 폴더명 추출 (books/the-art-of-unit-testing)
        # the-art-of-unit-testing 부분
        local folder_name="${normalized_ref#*/}"

        local md_files
        md_files=$(find "$file_path" -type f -name "*.md" | sort) || true

        while IFS= read -r md_file; do
          [ -z "$md_file" ] && continue

          if [ "$dry_run" = false ]; then
            # 파일 복사 전 링크 제거
            local temp_file
            temp_file=$(mktemp)
            cp "$md_file" "$temp_file"
            remove_obsidian_links "$temp_file"

            # 폴더 구조 유지: content/books/the-art-of-unit-testing/...
            local relative_path="${md_file#$file_path/}"
            local dest_file="$CONTENT_DIR/$dest_folder/$folder_name/$relative_path"
            mkdir -p "$(dirname "$dest_file")"
            mv "$temp_file" "$dest_file"
            log_success "  ✓ Synced: $folder_name/$(basename "$md_file")"
          else
            log_info "[DRY-RUN] Would sync: $(basename "$md_file")"
          fi
        done <<< "$md_files"
      fi
    else
      log_warning "Reference file not found: $reference"
    fi
  done <<< "$references"
}

# ============================================================
# 메인 함수
# ============================================================
main() {
  local source_path="$1"
  local dry_run=false

  # --dry-run 옵션 처리
  if [ $# -gt 1 ] && [ "$2" = "--dry-run" ]; then
    dry_run=true
  fi

  log_section "Syncing Single File"
  log_info "Source: $source_path"

  # ============================================================
  # 1. 유효성 검사
  # ============================================================

  # 파일 존재 여부
  if [ ! -f "$source_path" ]; then
    log_error "File does not exist: $source_path"
    exit 1
  fi

  # Obsidian vault 내에 있는지 확인
  if [[ "$source_path" != "$OBSIDIAN_VAULT"* ]]; then
    log_error "File must be inside Obsidian vault: $OBSIDIAN_VAULT"
    exit 1
  fi

  # 파일이 content 폴더 내에 있는지 확인
  if [[ "$source_path" == "$CONTENT_DIR"* ]]; then
    log_error "Cannot sync file from content folder: $source_path"
    exit 1
  fi

  # ============================================================
  # 2. 파일이 어느 폴더에 속하는지 판단
  # ============================================================

  local dest_folder=""

  if [[ "$source_path" == *"$BOOKS_SOURCE"* ]]; then
    dest_folder="$BOOKS_DEST"
    log_info "Destination: $dest_folder (books)"
  elif [[ "$source_path" == *"$WEB_CONTENTS_SOURCE"* ]]; then
    dest_folder="$WEB_CONTENTS_DEST"
    log_info "Destination: $dest_folder (web-contents)"
  elif [[ "$source_path" == *"$POSTS_SOURCE"* ]]; then
    dest_folder="$POSTS_DEST"
    log_info "Destination: $dest_folder (posts)"
  else
    log_error "File is not in any recognized source folder"
    log_error "Expected: $BOOKS_SOURCE, $WEB_CONTENTS_SOURCE, or $POSTS_SOURCE"
    exit 1
  fi

  # ============================================================
  # 3. 파일 복사
  # ============================================================

  log_section "Copying File"

  # 원본 파일의 상대 경로 추출 (source type 이후부터)
  local relative_path=""

  if [[ "$source_path" == *"$BOOKS_SOURCE"* ]]; then
    relative_path="${source_path#*$BOOKS_SOURCE/}"
  elif [[ "$source_path" == *"$WEB_CONTENTS_SOURCE"* ]]; then
    relative_path="${source_path#*$WEB_CONTENTS_SOURCE/}"
  elif [[ "$source_path" == *"$POSTS_SOURCE"* ]]; then
    relative_path="${source_path#*$POSTS_SOURCE/}"
  fi

  local dest_file="$CONTENT_DIR/$dest_folder/$relative_path"

  if [ "$dry_run" = false ]; then
    # 임시 파일 생성 (링크 제거 후)
    local temp_file
    temp_file=$(mktemp)
    cp "$source_path" "$temp_file"

    # 링크 제거
    if has_obsidian_links "$temp_file"; then
      log_info "Removing obsidian links..."
      remove_obsidian_links "$temp_file"
      log_success "Links removed"
    fi

    # 파일 복사
    mkdir -p "$(dirname "$dest_file")"
    mv "$temp_file" "$dest_file"
    log_success "File copied: $relative_path"
  else
    log_info "[DRY-RUN] Would copy file with links removed: $relative_path"
  fi

  # ============================================================
  # 4. 이미지 동기화
  # ============================================================

  log_section "Syncing Images"
  sync_images "$source_path" "$dry_run"
  sync_obsidian_embed_images "$source_path" "$dry_run"

  # ============================================================
  # 5. References 동기화 (posts만)
  # ============================================================

  if [[ "$dest_folder" == "$POSTS_DEST" ]]; then
    log_section "Syncing References"
    sync_referenced_files "$source_path" "$dry_run"
  fi

  log_success "File sync completed!"
  return 0
}

# ============================================================
# 스크립트 실행
# ============================================================

if [ $# -lt 1 ]; then
  echo "Usage: $0 <SOURCE_FILE> [--dry-run]"
  echo "Examples:"
  echo "  $0 /path/to/resources/books/file.md"
  echo "  $0 /path/to/resources/posts/post.md --dry-run"
  exit 1
fi

main "$@"
