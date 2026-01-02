#!/bin/bash

# organize-book-by-language.sh
# 책 폴더를 언어별로 분류하여 ko/books, en/books에 복사

if [ $# -ne 1 ]; then
    echo "사용법: $0 <책_폴더_경로>"
    echo "예: $0 /path/to/books/AI-2026-트렌드활용백과"
    exit 1
fi

SOURCE_DIR="$1"

# 소스 폴더 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo "오류: 소스 폴더가 없습니다: $SOURCE_DIR"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== 책을 언어별로 분류 시작 ==="
echo "소스: $SOURCE_DIR"
echo ""

# 매핑 파일 생성
echo "--- 매핑 파일 생성 ---"
"$SCRIPT_DIR/generate-mapping.sh" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo "오류: 매핑 파일 생성 실패"
    exit 1
fi
echo ""

# 한국어 요약본 복사
echo "--- 한국어 요약본 복사 ---"
"$SCRIPT_DIR/copy-korean-summaries.sh" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo "오류: 한국어 요약본 복사 실패"
    exit 1
fi
echo ""

# 영어 요약본 복사
echo "--- 영어 요약본 복사 ---"
"$SCRIPT_DIR/copy-english-summaries.sh" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo "오류: 영어 요약본 복사 실패"
    exit 1
fi
echo ""

# cover 이미지 복사
echo "--- Cover 이미지 복사 ---"
"$SCRIPT_DIR/copy-cover-image.sh" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo "오류: cover 이미지 복사 실패"
    exit 1
fi
echo ""

# Index 파일 생성
echo "--- Index 파일 생성 ---"
"$SCRIPT_DIR/create-book-index.sh" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo "오류: index 파일 생성 실패"
    exit 1
fi
echo ""

echo "=== 완료 ==="
