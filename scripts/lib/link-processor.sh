#!/bin/bash

# 링크를 재귀적으로 수집 및 처리하는 모듈
# 중복 제거 및 순환 참조 감지 포함
# 사용: collect_all_linked_files "file.md" "/path/to/vault"

collect_all_linked_files() {
  local source_file="$1"
  local vault="$2"
  local visited_file="/tmp/visited-links-$$"

  # 방문한 파일 추적
  > "$visited_file"

  # 재귀 함수
  _collect_recursive() {
    local file="$1"
    local depth="${2:-0}"

    # 무한 루프 방지 (깊이 제한: 10)
    if [ "$depth" -gt 10 ]; then
      return 0
    fi

    # 파일 존재 확인
    if [ ! -f "$file" ]; then
      return 0
    fi

    # 이미 방문한 파일인지 확인
    local file_base=$(basename "$file")
    if grep -q "^$file_base$" "$visited_file" 2>/dev/null; then
      return 0
    fi

    # 방문 표시
    echo "$file_base" >> "$visited_file"

    # 이 파일의 링크 추출
    local links=$(extract_obsidian_links "$file" 2>/dev/null || true)

    while IFS= read -r link; do
      if [ -z "$link" ]; then
        continue
      fi

      # 링크 해석
      if linked_file=$(resolve_link "$link" "$vault" 2>/dev/null); then
        # 절대 경로 출력
        echo "$linked_file"

        # 재귀적으로 링크된 파일의 링크 수집
        _collect_recursive "$linked_file" $((depth + 1))
      fi
    done <<< "$links"
  }

  # 시작
  _collect_recursive "$source_file" 0 | sort -u

  # 정리
  rm -f "$visited_file"
}
