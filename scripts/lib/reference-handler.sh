#!/bin/bash

# ============================================================
# Reference Handler Library
# 마크다운 참조 파일 동기화를 관리합니다
# ============================================================

# ============================================================
# 함수: 참조 필드 추출
# 입력: $1 = 마크다운 파일
# 출력: 참조 리스트 (한 줄에 하나씩)
# ============================================================
extract_references() {
  local file="$1"

  # references 필드에서 값 추출
  # - "[[path/to/file|display text]]" 형식 처리
  grep -A 10 "^references:" "$file" 2>/dev/null | \
    grep -oP '"\[\[\K[^|"]+' || true
}

# ============================================================
# 함수: 참조에서 경로 추출
# 입력: $1 = 참조 문자열
# 출력: 정규화된 경로 (예: books/the-art-of-unit-testing)
# ============================================================
extract_path_from_reference() {
  local reference="$1"

  # [[resources/books/book-name/file]] → resources/books/book-name
  # [[resources/web-contents/...]] → resources/web-contents/...
  # 마지막 경로 세그먼트(파일명) 제거

  # 경로 정규화: 슬래시 제거 및 경로 부분만 추출
  local path="${reference%/*}"  # 마지막 슬래시 이후 제거

  # resources/ 제거
  path="${path#resources/}"

  echo "$path"
}

# ============================================================
# 함수: 참조를 파일 경로로 해석
# 입력: $1 = 정규화된 참조 경로, $2 = Vault 경로
# 출력: 파일 경로
# ============================================================
resolve_reference_to_file() {
  local ref_path="$1"
  local vault="${2:-$OBSIDIAN_VAULT}"

  local file_path="$vault/resources/$ref_path.md"

  if [ -f "$file_path" ]; then
    echo "$file_path"
    return 0
  fi

  # 파일이 없으면 디렉토리로 시도
  local dir_path="$vault/resources/$ref_path"
  if [ -d "$dir_path" ]; then
    echo "$dir_path"
    return 0
  fi

  return 1
}

# ============================================================
# 함수: 참조된 파일들 동기화 (posts용)
# 입력: $1 = 마크다운 파일, $2 = DRY_RUN (선택사항)
# ============================================================
sync_referenced_files() {
  local file="$1"
  local dry_run="${2:-false}"

  log_debug "sync_referenced_files: processing $file"

  # references 필드 추출
  local references
  references=$(extract_references "$file") || return 0

  if [ -z "$references" ]; then
    log_info "No references field found"
    return 0
  fi

  log_info "Processing references..."

  while IFS= read -r reference; do
    [ -z "$reference" ] && continue

    # 경로 정규화
    local normalized_ref
    normalized_ref=$(extract_path_from_reference "$reference")

    log_debug "Reference: $reference → $normalized_ref"

    # 파일 또는 폴더 해석
    local file_path
    if ! file_path=$(resolve_reference_to_file "$normalized_ref" "$OBSIDIAN_VAULT"); then
      log_warning "Reference file not found: $reference"
      continue
    fi

    # 리소스 타입 판단 (books/web-contents)
    local source_type="${normalized_ref%%/*}"
    local dest_folder

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

    # 파일 또는 폴더 동기화
    if [ -f "$file_path" ]; then
      sync_referenced_file "$file_path" "$dest_folder" "$normalized_ref" "$dry_run"
    elif [ -d "$file_path" ]; then
      sync_referenced_folder "$file_path" "$dest_folder" "$normalized_ref" "$dry_run"
    fi
  done <<< "$references"

  return 0
}

# ============================================================
# 함수: 참조 파일 동기화 (내부)
# ============================================================
sync_referenced_file() {
  local file_path="$1"
  local dest_folder="$2"
  local normalized_ref="$3"
  local dry_run="$4"

  if [ "$dry_run" = false ]; then
    # 파일 복사 전 링크 제거
    local temp_file
    temp_file=$(mktemp)
    cp "$file_path" "$temp_file"
    source "$SCRIPT_DIR/lib/link-remover.sh"
    remove_obsidian_links "$temp_file"

    # 폴더 구조 유지: file_path에서 resources 이후 부분 추출
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
}

# ============================================================
# 함수: 참조 폴더 동기화 (내부)
# ============================================================
sync_referenced_folder() {
  local folder_path="$1"
  local dest_folder="$2"
  local normalized_ref="$3"
  local dry_run="$4"

  log_info "Processing folder: $normalized_ref"

  # 폴더명 추출 (books/the-art-of-unit-testing → the-art-of-unit-testing)
  local folder_name="${normalized_ref#*/}"

  # 폴더 내 마크다운 파일 찾기
  local md_files
  md_files=$(find "$folder_path" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort) || true

  while IFS= read -r md_file; do
    [ -z "$md_file" ] && continue

    if [ "$dry_run" = false ]; then
      # 파일 복사 전 링크 제거
      local temp_file
      temp_file=$(mktemp)
      cp "$md_file" "$temp_file"
      source "$SCRIPT_DIR/lib/link-remover.sh"
      remove_obsidian_links "$temp_file"

      # 폴더 구조 유지
      local relative_path="${md_file#$folder_path/}"
      local dest_file="$CONTENT_DIR/$dest_folder/$folder_name/$relative_path"
      mkdir -p "$(dirname "$dest_file")"
      mv "$temp_file" "$dest_file"
      log_success "  ✓ Synced: $folder_name/$(basename "$md_file")"
    else
      log_info "[DRY-RUN] Would sync: $(basename "$md_file")"
    fi
  done <<< "$md_files"
}
