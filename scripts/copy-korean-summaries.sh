#!/bin/bash

# copy-korean-summaries.sh
# 책 폴더에서 "요약"으로 시작하는 한국어 요약본을 ko/books로 복사
# mapping.json에서 영어 버전 정보를 읽어 frontmatter에 enVersion 추가

if [ $# -ne 1 ]; then
    echo "사용법: $0 <책_폴더_경로>"
    echo "예: $0 /path/to/books/AI-2026-트렌드활용백과"
    exit 1
fi

SOURCE_DIR="$1"
BOOK_NAME=$(basename "$SOURCE_DIR")
TARGET_BASE_DIR="/home/nadle/para/projects/content-management-system/content/ko/books"
TARGET_DIR="$TARGET_BASE_DIR/$BOOK_NAME"
MAPPING_FILE="$SOURCE_DIR/mapping.json"

# 소스 폴더 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo "오류: 소스 폴더가 없습니다: $SOURCE_DIR"
    exit 1
fi

# 타겟 디렉토리 생성
mkdir -p "$TARGET_DIR"
if [ $? -ne 0 ]; then
    echo "오류: 타겟 디렉토리 생성 실패: $TARGET_DIR"
    exit 1
fi

# ============================================================
# 함수: mapping.json에서 영어 파일명 찾기
# ============================================================
get_en_version() {
    local ko_filename="$1"

    if [ ! -f "$MAPPING_FILE" ]; then
        return 1
    fi

    # JSON에서 ko 값과 일치하는 en 값 추출
    grep -A 1 "\"ko\": \"$ko_filename\"" "$MAPPING_FILE" | grep "\"en\"" | sed 's/.*"en": "\([^"]*\)".*/\1/'
}

# ============================================================
# 함수: 파일의 frontmatter에 enVersion 추가
# ============================================================
add_en_version_to_frontmatter() {
    local file="$1"
    local en_version="$2"

    if [ -z "$en_version" ]; then
        return 0
    fi

    # 두 번째 --- 위치 찾기 (frontmatter 끝)
    local fm_end_line
    fm_end_line=$(sed -n '2,/^---$/=' "$file" | head -1)

    if [ -z "$fm_end_line" ]; then
        return 0
    fi

    # frontmatter의 닫는 --- 직전에 enVersion 추가
    sed -i "${fm_end_line}i enVersion: \"${en_version%.md}\"" "$file"
}

# "요약"으로 시작하는 파일 복사
count=0
while IFS= read -r file; do
    if [ -f "$file" ]; then
        ko_filename=$(basename "$file")
        dest_file="$TARGET_DIR/$ko_filename"

        cp "$file" "$dest_file"

        # mapping.json에서 영어 버전 찾기
        en_version=$(get_en_version "$ko_filename")

        if [ -n "$en_version" ]; then
            add_en_version_to_frontmatter "$dest_file" "$en_version"
            echo "복사: $ko_filename (enVersion: ${en_version%.md})"
        else
            echo "복사: $ko_filename"
        fi

        ((count++))
    fi
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f -name "요약*")

echo "한국어 요약본 $count개 복사 완료: $TARGET_DIR"
