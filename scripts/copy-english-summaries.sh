#!/bin/bash

# copy-english-summaries.sh
# 책 폴더에서 "summary"로 시작하는 영어 요약본을 en/books로 복사

if [ $# -ne 1 ]; then
    echo "사용법: $0 <책_폴더_경로>"
    echo "예: $0 /path/to/books/AI-2026-트렌드활용백과"
    exit 1
fi

SOURCE_DIR="$1"
BOOK_NAME=$(basename "$SOURCE_DIR")
TARGET_BASE_DIR="/home/nadle/para/projects/content-management-system/content/en/books"
TARGET_DIR="$TARGET_BASE_DIR/$BOOK_NAME"

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

# "summary"로 시작하는 파일 복사
count=0
while IFS= read -r file; do
    if [ -f "$file" ]; then
        cp "$file" "$TARGET_DIR/"
        echo "복사: $(basename "$file")"
        ((count++))
    fi
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f -name "summary*")

echo "영어 요약본 $count개 복사 완료: $TARGET_DIR"
