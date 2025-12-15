#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# 파일의 모든 wikilink 검증
# [[링크명]] 형식의 링크 검사
# public_dir: public 폴더의 절대경로 (옵션, 없으면 자동 계산)
validate_links_in_file() {
  local md_file="$1"
  local public_dir="${2:-.}"
  local broken_links=()
  local valid_links=()

  if [ ! -f "$md_file" ]; then
    log_error "File not found: $md_file"
    return 1
  fi

  # public_dir이 상대경로면 절대경로로 변환
  if [[ "$public_dir" != /* ]]; then
    public_dir="$(cd "$public_dir" 2>/dev/null && pwd)" || public_dir="."
  fi

  # [[링크]] 형식의 모든 링크 추출
  while IFS= read -r link; do
    if [ -z "$link" ]; then
      continue
    fi

    # 절대경로로 target 파일 구성
    local target_file="$public_dir/$link.md"

    # 파일이 존재하는지 확인
    if [ -f "$target_file" ]; then
      valid_links+=("$link")
    else
      broken_links+=("$link")
    fi
  done < <(grep -oP '\[\[\K[^\]]+' "$md_file" 2>/dev/null)

  # 결과 로깅
  if [ ${#broken_links[@]} -gt 0 ]; then
    log_warning "$md_file: ${#broken_links[@]} broken link(s)"
    for link in "${broken_links[@]}"; do
      log_warning "  - [[${link}]]"
    done
  fi

  if [ ${#valid_links[@]} -gt 0 ]; then
    log_info "$md_file: ${#valid_links[@]} valid link(s)"
  fi

  if [ ${#broken_links[@]} -eq 0 ]; then
    log_success "$md_file: No broken links"
    return 0
  else
    return 1
  fi
}

# 전체 public 폴더의 링크 검증
validate_all_links() {
  local public_dir="${1:-.}"
  local total_broken=0

  log_section "Validating all links"

  for md_file in "$public_dir"/**/*.md; do
    if [ -f "$md_file" ]; then
      if ! validate_links_in_file "$md_file"; then
        total_broken=$((total_broken + 1))
      fi
    fi
  done

  return $total_broken
}

# 깨진 링크 찾기 (검증 모드)
find_broken_links() {
  local public_dir="${1:-.}"
  local broken_count=0

  log_section "Finding broken links"

  while IFS= read -r link; do
    if [ -z "$link" ]; then
      continue
    fi

    local target_file="$public_dir/$link.md"
    if [ ! -f "$target_file" ]; then
      log_warning "Broken: [[${link}]]"
      broken_count=$((broken_count + 1))
    fi
  done < <(grep -rhP '\[\[\K[^\]]+' "$public_dir" 2>/dev/null | sort | uniq)

  if [ $broken_count -gt 0 ]; then
    log_warning "Found $broken_count broken link(s)"
    return 1
  else
    log_success "No broken links found"
    return 0
  fi
}
