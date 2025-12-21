#!/bin/bash

# ============================================================
# Path Resolver Library
# 경로 관련 작업을 중앙화합니다
# ============================================================

# ============================================================
# 함수: 절대 경로로 변환
# 입력: $1 = 상대 또는 절대 경로
# 출력: 절대 경로
# ============================================================
resolve_to_absolute_path() {
  local path="$1"

  # 이미 절대 경로면 그대로 반환
  if [[ "$path" == /* ]]; then
    echo "$path"
    return 0
  fi

  # Vault 내 상대 경로면 vault 경로와 결합
  local abs_path="$OBSIDIAN_VAULT/$path"

  echo "$abs_path"
  return 0
}

# ============================================================
# 함수: 상대 경로 추출
# 입력: $1 = 절대 경로, $2 = 기준 경로
# 출력: 상대 경로
# ============================================================
get_relative_path() {
  local abs_path="$1"
  local base_path="${2:-$OBSIDIAN_VAULT}"

  # 기준 경로가 없으면 아무것도 반환하지 않음
  if [[ ! "$abs_path" =~ ^"$base_path" ]]; then
    return 1
  fi

  # 상대 경로 추출
  echo "${abs_path#$base_path/}"
}

# ============================================================
# 함수: Vault 내 경로 여부 확인
# 입력: $1 = 경로
# 출력: 0 = vault 내, 1 = vault 외
# ============================================================
is_in_vault() {
  local path="$1"

  [[ "$path" == "$OBSIDIAN_VAULT"* ]]
}

# ============================================================
# 함수: Content 폴더 내 경로 여부 확인
# 입력: $1 = 경로
# 출력: 0 = content 내, 1 = content 외
# ============================================================
is_in_content_dir() {
  local path="$1"

  [[ "$path" == "$CONTENT_DIR"* ]]
}

# ============================================================
# 함수: 리소스 타입 판단 (books/web-contents/posts)
# 입력: $1 = 절대 경로
# 출력: 리소스 타입
# ============================================================
get_resource_type() {
  local path="$1"

  if [[ "$path" == *"$BOOKS_SOURCE"* ]]; then
    echo "books"
  elif [[ "$path" == *"$WEB_CONTENTS_SOURCE"* ]]; then
    echo "web-contents"
  elif [[ "$path" == *"$POSTS_SOURCE"* ]]; then
    echo "posts"
  else
    return 1
  fi
}

# ============================================================
# 함수: 대상 폴더 결정
# 입력: $1 = 리소스 타입
# 출력: 대상 폴더
# ============================================================
get_destination_folder() {
  local resource_type="$1"

  case "$resource_type" in
    books)
      echo "$BOOKS_DEST"
      ;;
    web-contents)
      echo "$WEB_CONTENTS_DEST"
      ;;
    posts)
      echo "$POSTS_DEST"
      ;;
    *)
      return 1
      ;;
  esac
}

# ============================================================
# 함수: 대상 파일 경로 생성
# 입력: $1 = 원본 파일 경로, $2 = 리소스 타입
# 출력: 대상 경로
# ============================================================
get_destination_file_path() {
  local source_file="$1"
  local resource_type="$2"

  local dest_folder
  dest_folder=$(get_destination_folder "$resource_type") || return 1

  local relative_path
  case "$resource_type" in
    books)
      relative_path="${source_file#*$BOOKS_SOURCE/}"
      ;;
    web-contents)
      relative_path="${source_file#*$WEB_CONTENTS_SOURCE/}"
      ;;
    posts)
      relative_path="${source_file#*$POSTS_SOURCE/}"
      ;;
    *)
      return 1
      ;;
  esac

  echo "$CONTENT_DIR/$dest_folder/$relative_path"
}

# ============================================================
# 함수: 경로 검증
# 입력: $1 = 경로
# 출력: 0 = 유효, 1 = 무효
# ============================================================
validate_path() {
  local path="$1"

  if [ -z "$path" ]; then
    log_error "Path is empty"
    return 1
  fi

  if [ ! -e "$path" ]; then
    log_error "Path does not exist: $path"
    return 1
  fi

  if ! is_in_vault "$path"; then
    log_error "Path must be inside Obsidian vault: $OBSIDIAN_VAULT"
    return 1
  fi

  if is_in_content_dir "$path"; then
    log_error "Cannot sync file from content folder: $path"
    return 1
  fi

  return 0
}
