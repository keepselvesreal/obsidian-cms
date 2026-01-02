#!/bin/bash

# copy-cover-image.sh
# 책 폴더에서 cover 이미지 파일을 ko/books, en/books에 복사

if [ $# -ne 1 ]; then
    echo "사용법: $0 <책_폴더_경로>"
    echo "예: $0 /path/to/books/AI-2026-트렌드활용백과"
    exit 1
fi

SOURCE_DIR="$1"
BOOK_NAME=$(basename "$SOURCE_DIR")

# 소스 폴더 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo "오류: 소스 폴더가 없습니다: $SOURCE_DIR"
    exit 1
fi

# cover 이미지 파일 찾기 (cover.jpg, cover.png 등)
cover_file=$(find "$SOURCE_DIR" -maxdepth 1 -iname "cover.*" -type f | head -1)

if [ -z "$cover_file" ]; then
    echo "경고: cover 이미지 파일을 찾을 수 없습니다"
    return 0
fi

# 한국어 책 폴더에 복사
KO_TARGET="/home/nadle/para/projects/content-management-system/content/ko/books/$BOOK_NAME"
if [ -d "$KO_TARGET" ]; then
    cp "$cover_file" "$KO_TARGET/"
    echo "복사: $(basename "$cover_file") → ko/books"
fi

# 영어 책 폴더에 복사
EN_TARGET="/home/nadle/para/projects/content-management-system/content/en/books/$BOOK_NAME"
if [ -d "$EN_TARGET" ]; then
    cp "$cover_file" "$EN_TARGET/"
    echo "복사: $(basename "$cover_file") → en/books"
fi

echo "cover 이미지 파일 복사 완료"
