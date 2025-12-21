#!/bin/bash

# ============================================================
# Reference Updater Library
# frontmatter의 references 필드를 CMS 경로로 변환합니다
# ============================================================

# ============================================================
# 함수: Frontmatter의 references 필드를 CMS 경로로 변환
# 입력: $1 = 마크다운 파일
# 처리: [[resources/books/...]] → [[/books/...]] 형식 변환
# ============================================================
convert_references_to_cms_paths() {
  local file="$1"

  log_debug "convert_references_to_cms_paths: processing $file"

  if [ ! -f "$file" ]; then
    log_warning "File not found: $file"
    return 1
  fi

  # frontmatter 끝 위치 찾기 (첫 라인은 ---, 두 번째 ---까지가 프론트매터)
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
  # [[resources/books/path/file]] → [[/books/path/file]]
  # [[resources/web-contents/path/file]] → [[/web-contents/path/file]]
  # [[resources/posts/path/file]] → [[/posts/path/file]]
  # display text와 함께 있는 경우도 처리
  # [[resources/books/path/file|display]] → [[/books/path/file|display]]

  perl -i -pe 's/\[\[resources\/books\/([^\]|]+)/[[\/books\/$1/g' "$temp_file"
  perl -i -pe 's/\[\[resources\/web-contents\/([^\]|]+)/[[\/web-contents\/$1/g' "$temp_file"
  perl -i -pe 's/\[\[resources\/posts\/([^\]|]+)/[[\/posts\/$1/g' "$temp_file"

  # 3. 본문 복사 (frontmatter 이후)
  tail -n +"$((frontmatter_lines + 1))" "$file" >> "$temp_file"

  # 4. 원본 파일에 적용
  mv "$temp_file" "$file"

  log_success "References converted to CMS paths"
  return 0
}
