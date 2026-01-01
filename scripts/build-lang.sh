#!/bin/bash
set -e

BUILD_LANG=$1

# content 백업 (처음 한 번만)
if [ ! -d ".content-backup" ]; then
  cp -r content .content-backup
fi

# 언어별 content 준비
rm -rf content
cp -r .content-backup/$BUILD_LANG content

# 빌드 (public/[lang]에 직접 생성)
mkdir -p public/$BUILD_LANG
LANG=$BUILD_LANG npx quartz build -o public/$BUILD_LANG

# content 복구
rm -rf content
cp -r .content-backup content
