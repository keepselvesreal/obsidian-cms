#!/bin/bash
set -e

# Content 구조 재정렬: ko 폴더 안의 파일들을 content 루트로 임시 이동
mkdir -p .content-build
cp -r content/ko/* .content-build/
cp -r content/attachments .content-build/ 2>/dev/null || true

# 임시 폴더로 교체
mv content content-backup
mv .content-build content

# 빌드
mkdir -p public/ko
LANG=ko npx quartz build -o public/ko

# 원래대로 복구
rm -rf content
mv content-backup content
