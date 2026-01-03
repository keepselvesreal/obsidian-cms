#!/bin/bash

set -e

echo "🚀 Cloudflare Pages 배포 시작..."
echo ""

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: KO 빌드
echo -e "${BLUE}[1/4] KO 버전 빌드 중...${NC}"
npm run build:ko
echo -e "${GREEN}✅ KO 빌드 완료${NC}"
echo ""

# Step 2: EN 빌드
echo -e "${BLUE}[2/4] EN 버전 빌드 중...${NC}"
npm run build:en
echo -e "${GREEN}✅ EN 빌드 완료${NC}"
echo ""

# Step 3: KO 배포
echo -e "${BLUE}[3/4] KO 프로젝트 배포 중...${NC}"
npx wrangler pages deploy public/ko --project-name knowledge-sherpa-ko
echo -e "${GREEN}✅ KO 배포 완료${NC}"
echo ""

# Step 4: EN 배포
echo -e "${BLUE}[4/4] EN 프로젝트 배포 중...${NC}"
npx wrangler pages deploy public/en --project-name knowledge-sherpa-en
echo -e "${GREEN}✅ EN 배포 완료${NC}"
echo ""

echo -e "${GREEN}🎉 모든 배포가 완료되었습니다!${NC}"
echo ""
echo "📍 배포 확인:"
echo "   KO: https://ko.knowledge-sherpa.com"
echo "   EN: https://en.knowledge-sherpa.com"
