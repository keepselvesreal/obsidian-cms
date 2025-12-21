#!/bin/bash

# ============================================================
# Reference Updater Library
# frontmatter의 references 필드를 CMS 경로로 변환하고
# 본문 끝에 참조 섹션을 마크다운 링크로 추가합니다
# ============================================================

# ============================================================
# 함수: References 배열 파싱 (frontmatter에서)
# 입력: $1 = 마크다운 파일, $2 = 시작 라인 번호, $3 = 끝 라인 번호
# 출력: references 항목들 (한 줄에 하나씩)
# ============================================================
extract_references_from_frontmatter() {
  local file="$1"
  local start_line="$2"
  local end_line="$3"

  # frontmatter에서 references: 부터 다음 필드까지 추출
  sed -n "${start_line},${end_line}p" "$file" | \
    sed -n '/^references:/,/^[a-z]/p' | \
    grep '^\s*- "' | \
    sed 's/.*- "//' | \
    sed 's/"$//' || true
}

# ============================================================
# 함수: Reference 항목에서 경로와 텍스트 추출
# 입력: $1 = reference 항목 ([[resources/books/path/file|text]])
# 출력: cms_path|text 형식 (예: /books/path/file|text)
# ============================================================
parse_reference_item() {
  local ref="$1"

  # [[resources/books/path/file|text]] → path, text 추출
  local path_part="${ref#\[\[}"    # [[제거
  path_part="${path_part%\]\]}"    # ]]제거

  local path="${path_part%%|*}"    # |전까지가 경로
  local text="${path_part##*|}"    # |이후가 텍스트

  # resources/ 제거하고 /로 시작하게 변환
  path="${path#resources}"

  echo "${path}|${text}"
}

# ============================================================
# 함수: Frontmatter의 references 필드를 CMS 경로로 변환하고
#       본문 끝에 참조 섹션 추가
# 입력: $1 = 마크다운 파일
# ============================================================
convert_references_to_cms_paths() {
  local file="$1"

  log_debug "convert_references_to_cms_paths: processing $file"

  if [ ! -f "$file" ]; then
    log_warning "File not found: $file"
    return 1
  fi

  # frontmatter 끝 위치 찾기
  local frontmatter_lines
  frontmatter_lines=$(awk '/^---$/{count++; if(count==2){print NR; exit}}' "$file")

  # frontmatter가 없으면 처리 안 함
  if [ -z "$frontmatter_lines" ]; then
    log_debug "convert_references_to_cms_paths: no frontmatter found"
    return 0
  fi

  # 임시 파일 생성
  local temp_file="${file}.tmp"

  # 1. frontmatter 복사
  head -n "$frontmatter_lines" "$file" > "$temp_file"

  # 2. frontmatter 내에서 references 경로 변환 (perl 사용)
  perl -i -pe 's/\[\[resources\/books\/([^\]|]+)/[[\/books\/$1/g' "$temp_file"
  perl -i -pe 's/\[\[resources\/web-contents\/([^\]|]+)/[[\/web-contents\/$1/g' "$temp_file"
  perl -i -pe 's/\[\[resources\/posts\/([^\]|]+)/[[\/posts\/$1/g' "$temp_file"

  # 3. 본문 복사
  tail -n +"$((frontmatter_lines + 1))" "$file" >> "$temp_file"

  # 4. References 파싱 및 참조 섹션 생성
  local references
  references=$(extract_references_from_frontmatter "$file" 1 "$frontmatter_lines")

  if [ -n "$references" ]; then
    # 본문 끝에 세 줄 공백 추가 (2줄 간격)
    echo "" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "" >> "$temp_file"

    # --- 구분선 추가
    echo "---" >> "$temp_file"

    # 참조 섹션 추가
    echo "참조" >> "$temp_file"

    # 각 reference를 마크다운 링크로 변환하여 추가
    while IFS= read -r ref; do
      [ -z "$ref" ] && continue

      local parsed
      parsed=$(parse_reference_item "$ref")

      local cms_path="${parsed%%|*}"
      local text="${parsed##*|}"

      # 기본 파일 링크 추가
      echo "- [$text]($cms_path)" >> "$temp_file"

      # 영어 버전 파일 확인 및 추가
      local en_file="${cms_path}-en"
      local obsidian_en_file="${ref#\[\[}"
      obsidian_en_file="${obsidian_en_file%\]\]}"
      obsidian_en_file="${obsidian_en_file%%|*}"
      obsidian_en_file="${obsidian_en_file%.md}-en.md"

      # Obsidian vault에서 -en 파일 존재 확인
      if [ -f "$OBSIDIAN_VAULT/$obsidian_en_file" ]; then
        echo "- [$text (EN)]($en_file)" >> "$temp_file"
      fi
    done <<< "$references"
  fi

  # 5. 원본 파일에 적용
  mv "$temp_file" "$file"

  log_success "References converted and references section added"
  return 0
}
