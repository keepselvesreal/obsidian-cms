#!/bin/bash

# Sync-to-Public 설정 파일
# 이 파일에서 기본값을 정의합니다.
# 필요한 경우 값을 변경하고 저장하세요.

# Obsidian Vault 경로
OBSIDIAN_VAULT="/home/nadle/문서/google-drive-obsidian"

# Public 폴더 경로 (Vault 내 상대 경로)
PUBLIC_SUBDIR="public"
PUBLIC_DIR="$OBSIDIAN_VAULT/$PUBLIC_SUBDIR"

# 원본 첨부파일 디렉토리 (Vault 내 상대 경로)
# 이미지를 찾아서 public/attachments로 복사할 때 사용
SOURCE_ATTACHMENTS_SUBDIR="resources/attachments"
SOURCE_ATTACHMENTS_DIR="$OBSIDIAN_VAULT/$SOURCE_ATTACHMENTS_SUBDIR"

# Dry-run 모드 (변경 없이 시뮬레이션만 실행)
# true: 실행하지 않고 로깅만 함
# false: 실제로 파일 복사 실행
DRY_RUN=false

# 자동 링크 포함 모드
# true: 사용자 확인 없이 linked 파일 자동 복사
# false: 사용자에게 매번 물어봄
AUTO_INCLUDE_LINKS=false
