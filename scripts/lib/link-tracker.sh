#!/bin/bash

# ============================================================
# Link Tracker Library
# 마크다운 파일의 모든 링크를 추적하고 순환 참조를 방지합니다.
# ============================================================

set -euo pipefail

# 라이브러리 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logger.sh"

# ============================================================
# 전역 변수
# ============================================================

# 이미 처리된 파일들 (순환 참조 방지)
declare -gA PROCESSED_FILES=()

# 링크 추적 깊이 기록
declare -gA LINK_DEPTH=()

# ============================================================
# 함수: 링크 추적 초기화
# ============================================================
init_link_tracker() {
  PROCESSED_FILES=()
  LINK_DEPTH=()
}

# ============================================================
# 함수: 이미지 링크 추출 (![alt](path) 형식)
# 출력: 이미지 경로 목록
# ============================================================
extract_image_links() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # 마크다운 이미지 링크: ![...](path)
  # path는 상대 경로 또는 절대 경로
  grep -oP '!\[.*?\]\(\K[^)]+' "$file" 2>/dev/null || true
}

# ============================================================
# 함수: Obsidian 링크 추출 ([[path]] 형식)
# 출력: 링크 목록 (|로 구분된 텍스트 제거 전)
# ============================================================
extract_obsidian_links() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # Obsidian 링크: [[path]] 또는 [[path|display-text]]
  grep -oP '\[\[\K[^\]]+(?=\]\])' "$file" 2>/dev/null || true
}

# ============================================================
# 함수: 파일이 이미 처리되었는지 확인 (순환 참조 방지)
# 반환: 0 = 처리됨, 1 = 미처리
# ============================================================
is_already_processed() {
  local file="$1"

  # 절대 경로로 정규화
  local abs_file
  abs_file=$(cd "$(dirname "$file")" && pwd)/$(basename "$file")

  if [[ -v PROCESSED_FILES["$abs_file"] ]]; then
    return 0  # 이미 처리됨
  fi

  return 1  # 미처리
}

# ============================================================
# 함수: 파일을 처리됨으로 표시
# ============================================================
mark_file_as_processed() {
  local file="$1"
  local depth=$2

  # 절대 경로로 정규화
  local abs_file
  abs_file=$(cd "$(dirname "$file")" && pwd)/$(basename "$file")

  PROCESSED_FILES["$abs_file"]=1
  LINK_DEPTH["$abs_file"]=$depth
}

# ============================================================
# 함수: 상대 경로를 절대 경로로 변환
# 입력: $1 = 상대 경로, $2 = 기준 파일 경로
# 출력: 절대 경로
# ============================================================
resolve_relative_path() {
  local relative_path="$1"
  local reference_file="$2"  # 기준이 되는 파일의 절대 경로

  local reference_dir
  reference_dir=$(dirname "$reference_file")

  # 상대 경로를 절대 경로로 변환
  local absolute_path
  absolute_path=$(cd "$reference_dir" && cd "$(dirname "$relative_path")" && pwd)/$(basename "$relative_path")

  echo "$absolute_path"
}

# ============================================================
# 함수: Obsidian 링크를 파일 경로로 변환
# 입력: $1 = Obsidian 링크 (path 또는 path|text)
#       $2 = Vault 경로
#       $3 = 기준 파일 경로
# 출력: 파일 절대 경로
# ============================================================
resolve_obsidian_link() {
  local link="$1"
  local vault="$2"
  local reference_file="$3"

  # [[path|text]] 형식에서 경로만 추출
  local path="${link%%|*}"

  # 경로가 비어있으면 오류
  if [ -z "$path" ]; then
    return 1
  fi

  # 상대 경로인 경우 기준 파일 기준으로 해석
  if [[ "$path" != /* ]]; then
    # 기준 파일의 디렉토리를 기준으로 상대 경로 해석
    local reference_dir
    reference_dir=$(dirname "$reference_file")
    path=$(cd "$reference_dir" && cd "$(dirname "$path")" && pwd)/$(basename "$path")
  fi

  # .md 확장자 추가 (없을 경우)
  if [ ! -f "$path" ]; then
    local path_with_md="${path%.md}.md"
    if [ -f "$path_with_md" ]; then
      path="$path_with_md"
    fi
  fi

  # 파일 존재 확인
  if [ ! -f "$path" ]; then
    return 1
  fi

  echo "$path"
  return 0
}

# ============================================================
# 함수: 이미지 링크를 파일 경로로 변환
# 입력: $1 = 이미지 경로 (상대 경로)
#       $2 = 기준 파일 경로 (절대 경로)
# 출력: 파일 절대 경로
# ============================================================
resolve_image_link() {
  local image_path="$1"
  local reference_file="$2"

  local reference_dir
  reference_dir=$(dirname "$reference_file")

  # 상대 경로를 절대 경로로 변환
  local absolute_path
  absolute_path=$(cd "$reference_dir" && cd "$(dirname "$image_path")" && pwd)/$(basename "$image_path")

  # 파일 존재 확인
  if [ ! -f "$absolute_path" ]; then
    return 1
  fi

  echo "$absolute_path"
  return 0
}

# ============================================================
# 함수: 파일의 모든 링크 추출 (Obsidian + 이미지)
# 입력: $1 = 마크다운 파일 경로
#       $2 = Vault 경로
# 출력: 링크된 파일 경로 목록 (한 줄에 하나)
# ============================================================
extract_all_linked_files() {
  local file="$1"
  local vault="$2"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # Obsidian 링크 처리
  local obsidian_links
  obsidian_links=$(extract_obsidian_links "$file")

  while IFS= read -r link; do
    [ -z "$link" ] && continue

    local resolved
    if resolved=$(resolve_obsidian_link "$link" "$vault" "$file"); then
      echo "$resolved"
    fi
  done <<< "$obsidian_links"

  # 이미지 링크 처리
  local image_links
  image_links=$(extract_image_links "$file")

  while IFS= read -r img_path; do
    [ -z "$img_path" ] && continue

    local resolved
    if resolved=$(resolve_image_link "$img_path" "$file"); then
      echo "$resolved"
    fi
  done <<< "$image_links"
}

# ============================================================
# 함수: 링크된 파일들을 깊이 제한까지 재귀적으로 추적
# 입력: $1 = 시작 파일 경로
#       $2 = Vault 경로
#       $3 = 현재 깊이
#       $4 = 최대 깊이
# 출력: 모든 링크된 파일 목록 (처리 순서대로)
# ============================================================
track_linked_files() {
  local file="$1"
  local vault="$2"
  local current_depth="${3:-0}"
  local max_depth="${4:-$MAX_LINK_DEPTH}"

  # 파일이 없으면 스킵
  if [ ! -f "$file" ]; then
    return 1
  fi

  # 순환 참조 감지
  if is_already_processed "$file"; then
    log_warning "Circular reference detected: $file"
    return 0
  fi

  # 최대 깊이 도달
  if [ "$current_depth" -ge "$max_depth" ]; then
    log_info "Max link depth reached ($max_depth): $file"
    return 0
  fi

  # 현재 파일을 처리됨으로 표시
  mark_file_as_processed "$file" "$current_depth"

  # 현재 파일 출력
  echo "$file"

  # 링크된 파일들 추적
  local linked_files
  linked_files=$(extract_all_linked_files "$file" "$vault") || true

  while IFS= read -r linked_file; do
    [ -z "$linked_file" ] && continue

    # 재귀적으로 추적
    track_linked_files "$linked_file" "$vault" $((current_depth + 1)) "$max_depth"
  done <<< "$linked_files"

  return 0
}

# ============================================================
# 함수: 최종 처리된 파일 목록 반환
# 출력: 정렬된 파일 경로 목록
# ============================================================
get_processed_files() {
  for file in "${!PROCESSED_FILES[@]}"; do
    echo "$file"
  done | sort
}

# ============================================================
# 함수: 처리된 파일 개수 반환
# ============================================================
get_processed_files_count() {
  echo "${#PROCESSED_FILES[@]}"
}
