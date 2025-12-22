#!/bin/bash

# ============================================================
# Sync Obsidian to CMS Configuration
# ============================================================

# Obsidian Vault 경로
OBSIDIAN_VAULT="/home/nadle/문서/google-drive-obsidian"

# Content 폴더 경로 (프로젝트 내)
CONTENT_DIR="/home/nadle/para/projects/content-management-system/content"

# ============================================================
# 폴더 매핑 (resources → content)
# ============================================================

BOOKS_SOURCE="resources/books"
BOOKS_DEST="books"

WEB_CONTENTS_SOURCE="resources/web-contents"
WEB_CONTENTS_DEST="web-contents"

POSTS_SOURCE="resources/posts"
POSTS_DEST="posts"

ATTACHMENTS_DEST="attachments"

# ============================================================
# 링크 처리 옵션
# ============================================================

# 최대 링크 추적 깊이 (순환 참조 방지)
MAX_LINK_DEPTH=5

# ============================================================
# Cover Image 설정
# ============================================================

# Cover 이미지 크기 (책 표지 크기)
COVER_IMAGE_WIDTH="300px"
COVER_IMAGE_HEIGHT="450px"

# ============================================================
# 실행 모드 옵션
# ============================================================

# Dry-run 모드 (변경 없이 시뮬레이션만 실행)
# true: 로깅만 함, false: 실제로 파일 복사
DRY_RUN=false
