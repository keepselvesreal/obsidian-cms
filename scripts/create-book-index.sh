#!/bin/bash

# create-book-index.sh
# 책 폴더의 ko, en 언어별 폴더에 index.md를 자동으로 생성합니다

if [ $# -ne 1 ]; then
    echo "사용법: $0 <책_폴더_경로>"
    echo "예: $0 /path/to/books/AI-2026-트렌드활용백과"
    exit 1
fi

SOURCE_DIR="$1"
BOOK_NAME=$(basename "$SOURCE_DIR")

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# config 로드
source "$SCRIPT_DIR/config.sh"

# 소스 폴더 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo "오류: 소스 폴더가 없습니다: $SOURCE_DIR"
    exit 1
fi

# ============================================================
# 함수: 언어별 index.md 생성
# 입력: $1 = 타겟 폴더 경로, $2 = 언어 (ko/en)
# ============================================================
create_book_index() {
    local target_folder="$1"
    local language="$2"
    local index_file="$target_folder/index.md"

    # 타겟 폴더 존재 확인
    if [ ! -d "$target_folder" ]; then
        echo "오류: 타겟 폴더가 없습니다: $target_folder"
        return 1
    fi

    # 이미 index.md가 있으면 덮어쓰기

    # 책 제목
    local title="${BOOK_NAME//-/ }"

    # 섹션 헤더 (언어별)
    local section_header
    if [ "$language" = "ko" ]; then
        section_header="## 요약 자료"
    else
        section_header="## Summary Materials"
    fi

    # frontmatter 생성
    {
        echo "---"
        echo "title: \"$title\""
        echo "---"
        echo ""

        # Cover 이미지 삽입
        if [ -f "$target_folder/cover.jpg" ] || [ -f "$target_folder/cover.png" ]; then
            echo "<img src=\"./cover.jpg\" width=\"${COVER_IMAGE_WIDTH:-300px}\" height=\"${COVER_IMAGE_HEIGHT:-450px}\" alt=\"cover\" style=\"border-radius: 8px; display: block; margin: 2rem auto 0;\" />"
            echo ""
        fi

        # 요약 자료 섹션
        echo "$section_header"
        echo ""

        # 언어별 요약 파일 찾기 및 링크 생성
        if [ "$language" = "ko" ]; then
            # 한국어: 요약-*.md 파일들
            find "$target_folder" -maxdepth 1 -type f -name "요약*.md" | sort | while read -r file; do
                filename=$(basename "$file" .md)
                echo "- [[$filename]]"
            done
        else
            # 영어: summary-*.md 파일들
            find "$target_folder" -maxdepth 1 -type f -name "summary*.md" | sort | while read -r file; do
                filename=$(basename "$file" .md)
                echo "- [[$filename]]"
            done
        fi
    } > "$index_file"

    echo "생성: $(basename "$target_folder")/index.md ($language)"
    return 0
}

# ============================================================
# 한국어 폴더
# ============================================================
KO_TARGET="/home/nadle/para/projects/content-management-system/content/ko/books/$BOOK_NAME"
if [ -d "$KO_TARGET" ]; then
    echo "--- 한국어 index.md 생성 ---"
    create_book_index "$KO_TARGET" "ko"
    if [ $? -eq 0 ]; then
        echo "✓ 완료"
    fi
    echo ""
fi

# ============================================================
# 영어 폴더
# ============================================================
EN_TARGET="/home/nadle/para/projects/content-management-system/content/en/books/$BOOK_NAME"
if [ -d "$EN_TARGET" ]; then
    echo "--- 영어 index.md 생성 ---"
    create_book_index "$EN_TARGET" "en"
    if [ $? -eq 0 ]; then
        echo "✓ 완료"
    fi
    echo ""
fi

echo "=== Index 파일 생성 완료 ==="
