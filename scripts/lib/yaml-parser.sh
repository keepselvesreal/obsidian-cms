#!/bin/bash

# ============================================================
# YAML Parser Library
# 마크다운 파일의 YAML 프론트매터를 파싱합니다.
# ============================================================

set -euo pipefail

# ============================================================
# 함수: YAML 프론트매터 추출
# 입력: $1 = 마크다운 파일 경로
# 출력: YAML 프론트매터 (--- 포함)
# ============================================================
extract_frontmatter() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # 첫 번째 라인이 ---인지 확인
  if ! head -1 "$file" | grep -q "^---$"; then
    return 1
  fi

  # 첫 번째 ---부터 다음 ---까지 추출
  awk '/^---$/{count++; next} count==1' "$file" | head -n $(awk '/^---$/{count++; if(count==2) {print NR; exit}}' "$file")
}

# ============================================================
# 함수: YAML 필드값 추출
# 입력: $1 = 필드명 (예: "references")
#       $2 = YAML 프론트매터 (stdin 또는 여러 줄)
# 출력: 필드값 (배열은 리스트로)
# ============================================================
extract_yaml_field() {
  local field="$1"

  # 필드명 찾기 및 값 추출
  grep "^${field}:" | sed "s/^${field}:\s*//g"
}

# ============================================================
# 함수: YAML 배열 필드 추출 (references 등)
# 입력: $1 = 필드명
#       $2 = YAML 프론트매터
# 출력: 배열 항목들 (한 줄에 하나)
# ============================================================
extract_yaml_array() {
  local field="$1"
  local frontmatter="$2"

  # 필드명부터 다음 필드까지의 내용 추출
  echo "$frontmatter" | awk -v field="$field" '
    $0 ~ "^" field ":" {
      in_field = 1
      next
    }
    /^[^ ]/ && NF > 0 && in_field {
      in_field = 0
    }
    in_field && /^ *- / {
      # 배열 항목 추출 (- 앞의 공백 제거, 따옴표 제거)
      gsub(/^ *- /, "")
      gsub(/^"/, "")
      gsub(/"$/, "")
      print
    }
  '
}

# ============================================================
# 함수: 마크다운 파일에서 references 배열 추출
# 입력: $1 = 마크다운 파일 경로
# 출력: references 항목들 (한 줄에 하나)
# ============================================================
extract_references() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # YAML 프론트매터 추출
  local frontmatter
  frontmatter=$(extract_frontmatter "$file") || return 1

  # references 배열 추출
  extract_yaml_array "references" "$frontmatter"
}

# ============================================================
# 함수: references에서 파일 경로로 변환
# 입력: $1 = references 항목 (예: "books/the-art-of-unit-testing")
#       $2 = Vault 경로
# 출력: 절대 파일 경로
# ============================================================
resolve_reference_to_file() {
  local reference="$1"
  local vault="$2"

  # reference는 "books/path" 또는 "web-contents/path" 형식
  local source_path="$vault/resources/$reference"

  # .md 확장자 추가 (없으면)
  if [ ! -f "$source_path" ] && [ ! -d "$source_path" ]; then
    if [ -f "${source_path}.md" ]; then
      source_path="${source_path}.md"
    fi
  fi

  # 파일/폴더 존재 여부 확인
  if [ ! -e "$source_path" ]; then
    return 1
  fi

  echo "$source_path"
  return 0
}

# ============================================================
# 함수: references 배열에서 링크 경로 추출 ([[...]] 형식 처리)
# 입력: $1 = references 항목 (예: "[[resources/books/...]]" 또는 경로)
# 출력: 정규화된 경로 (books/path 형식)
# ============================================================
extract_path_from_reference() {
  local reference="$1"

  # [[...]] 형식 제거
  reference="${reference//\[\[/}"
  reference="${reference//\]\]/}"

  # |로 구분된 text 부분 제거 ([[path|text]] 형식)
  reference="${reference%%|*}"

  # 따옴표 제거
  reference="${reference//\"/}"

  # "resources/" 프리픽스 제거 (있으면)
  if [[ "$reference" == "resources/"* ]]; then
    reference="${reference#resources/}"
  fi

  echo "$reference"
}

# ============================================================
# 함수: references 항목들을 파일 경로로 변환
# 입력: $1 = 마크다운 파일 경로
#       $2 = Vault 경로
# 출력: 파일 경로들 (한 줄에 하나)
# ============================================================
extract_references_files() {
  local file="$1"
  local vault="$2"

  local references
  references=$(extract_references "$file") || return 1

  while IFS= read -r reference; do
    [ -z "$reference" ] && continue

    # [[...]] 형식 처리
    local normalized_ref
    normalized_ref=$(extract_path_from_reference "$reference")

    local file_path
    if file_path=$(resolve_reference_to_file "$normalized_ref" "$vault"); then
      echo "$file_path"
    fi
  done <<< "$references"
}
