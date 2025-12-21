#!/bin/bash

# ============================================================
# Test Mode Handler Library
# 개별 함수 테스트 모드를 제공합니다
# ============================================================

# ============================================================
# 함수: 테스트 모드 확인
# 입력: $1 = 옵션 배열명
# 출력: 0 = 테스트 모드, 1 = 일반 모드
# ============================================================
is_test_mode() {
  local opts_var="$1"

  local test_mode
  eval "test_mode=\${${opts_var}[test_mode]}"
  [ "$test_mode" = true ]
}

# ============================================================
# 함수: 테스트 대상 확인
# 입력: $1 = 옵션 배열명
# 출력: 테스트 대상명
# ============================================================
get_test_target() {
  local opts_var="$1"

  local test_target
  eval "test_target=\${${opts_var}[test_target]}"
  echo "$test_target"
}

# ============================================================
# 함수: 경로 해석 테스트
# 입력: $1 = 테스트 파일 경로
# ============================================================
test_path_resolver() {
  local test_file="$1"

  log_section "Test: Path Resolver"

  log_info "Input: $test_file"
  log_info "Is in vault: $(is_in_vault "$test_file" && echo 'YES' || echo 'NO')"
  log_info "Is in content: $(is_in_content_dir "$test_file" && echo 'YES' || echo 'NO')"

  local resource_type
  if resource_type=$(get_resource_type "$test_file"); then
    log_success "Resource type: $resource_type"

    local dest_folder
    if dest_folder=$(get_destination_folder "$resource_type"); then
      log_success "Destination folder: $dest_folder"

      local dest_path
      if dest_path=$(get_destination_file_path "$test_file" "$resource_type"); then
        log_success "Destination path: $dest_path"
      fi
    fi
  else
    log_error "Unknown resource type"
  fi

  log_success "Path resolver test completed"
}

# ============================================================
# 함수: 링크 제거 테스트
# 입력: $1 = 테스트 파일 경로
# ============================================================
test_link_remover() {
  local test_file="$1"

  log_section "Test: Link Remover"

  if [ ! -f "$test_file" ]; then
    log_error "Test file not found: $test_file"
    return 1
  fi

  log_info "Testing link removal..."
  log_info "Original content:"
  head -20 "$test_file" | sed 's/^/  /'

  # 백업 생성
  local backup="${test_file}.test-backup"
  cp "$test_file" "$backup"

  # 링크 제거 (임시 파일로)
  local temp_file
  temp_file=$(mktemp)
  cp "$test_file" "$temp_file"
  remove_obsidian_links "$temp_file"

  log_success "After link removal:"
  head -20 "$temp_file" | sed 's/^/  /'

  # 원본 복원
  mv "$backup" "$test_file"
  rm -f "$temp_file"

  log_success "Link remover test completed"
}

# ============================================================
# 함수: 이미지 추출 테스트
# 입력: $1 = 테스트 파일 경로
# ============================================================
test_image_extraction() {
  local test_file="$1"

  log_section "Test: Image Extraction"

  if [ ! -f "$test_file" ]; then
    log_error "Test file not found: $test_file"
    return 1
  fi

  log_info "Finding markdown images..."
  local md_images
  md_images=$(grep -oP '!\[.*?\]\(\K[^)]+' "$test_file" 2>/dev/null || true)

  if [ -n "$md_images" ]; then
    log_success "Found markdown images:"
    echo "$md_images" | sed 's/^/  /'
  else
    log_info "No markdown images found"
  fi

  log_info "Finding Obsidian embed images..."
  local embed_images
  embed_images=$(grep -oP '!\[\[\K[^\]|]+' "$test_file" 2>/dev/null || true)

  if [ -n "$embed_images" ]; then
    log_success "Found Obsidian embed images:"
    echo "$embed_images" | sed 's/^/  /'
  else
    log_info "No Obsidian embed images found"
  fi

  log_success "Image extraction test completed"
}

# ============================================================
# 함수: 참조 추출 테스트
# 입력: $1 = 테스트 파일 경로
# ============================================================
test_reference_extraction() {
  local test_file="$1"

  log_section "Test: Reference Extraction"

  if [ ! -f "$test_file" ]; then
    log_error "Test file not found: $test_file"
    return 1
  fi

  log_info "Extracting references..."
  local references
  references=$(extract_references "$test_file") || true

  if [ -n "$references" ]; then
    log_success "Found references:"
    while IFS= read -r ref; do
      [ -z "$ref" ] && continue
      local normalized
      normalized=$(extract_path_from_reference "$ref")
      log_info "  $ref → $normalized"
    done <<< "$references"
  else
    log_info "No references found"
  fi

  log_success "Reference extraction test completed"
}

# ============================================================
# 함수: 테스트 모드 실행
# 입력: $1 = 옵션 배열명, $2 = 테스트 파일 경로
# ============================================================
run_test_mode() {
  local opts_var="$1"
  local test_file="$2"

  if ! is_test_mode "$opts_var"; then
    return 0
  fi

  local test_target
  test_target=$(get_test_target "$opts_var")

  log_section "Test Mode: $test_target"

  case "$test_target" in
    path-resolver)
      test_path_resolver "$test_file"
      ;;
    link-remover)
      test_link_remover "$test_file"
      ;;
    image-extraction)
      test_image_extraction "$test_file"
      ;;
    reference-extraction)
      test_reference_extraction "$test_file"
      ;;
    *)
      log_error "Unknown test target: $test_target"
      log_info "Available tests: path-resolver, link-remover, image-extraction, reference-extraction"
      return 1
      ;;
  esac

  exit 0
}
