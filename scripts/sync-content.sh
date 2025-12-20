#!/bin/bash

set -euo pipefail

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/index-generator.sh"

# 설정 변수
OBSIDIAN_VAULT="/home/nadle/문서/google-drive-obsidian"
PUBLIC_DIR="$OBSIDIAN_VAULT/public"
CONTENT_DIR="$PROJECT_ROOT/content"
DRY_RUN=false

# 옵션 처리
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verbose)
      set -x
      shift
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done

# 헬프 출력
print_help() {
  cat << 'EOF'
Usage: ./sync-content.sh [OPTIONS]

Options:
  --dry-run           Run without making changes (preview mode)
  --verbose           Show all bash commands
  --help              Show this help message

Examples:
  ./sync-content.sh                    # Normal sync
  ./sync-content.sh --dry-run          # Preview changes
  ./sync-content.sh --verbose          # Debug mode

Description:
  Syncs content from public folder to content folder using rsync.
  All image processing and file preparation should be done via sync-to-public.sh

Logs:
  Latest log: logs/sync-latest.log
  Dated logs: logs/25-12-15-1100.log
EOF
}

# 메인 함수
main() {
  log_section "Sync to Content Started"
  log_info "Working directory: $PROJECT_ROOT"
  log_info "Public folder: $PUBLIC_DIR"
  log_info "Content folder: $CONTENT_DIR"
  log_info "Log file: $LOG_FILE"

  if [ "$DRY_RUN" = true ]; then
    log_warning "DRY-RUN MODE: No changes will be made"
  fi

  # 시작 시간
  START_TIME=$(date +%s)

  # 폴더 존재 여부 확인
  if [ ! -d "$PUBLIC_DIR" ]; then
    log_error "Public folder not found: $PUBLIC_DIR"
    exit 1
  fi

  if [ ! -d "$CONTENT_DIR" ]; then
    log_info "Creating content directory: $CONTENT_DIR"
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$CONTENT_DIR"
    fi
  fi

  # 동기화: public 폴더 → content 폴더
  log_section "Syncing public to content"

  if [ "$DRY_RUN" = false ]; then
    if rsync -av --delete "$PUBLIC_DIR/" "$CONTENT_DIR/" 2>&1 | tee -a "$LOG_FILE" "$LOG_LATEST"; then
      log_success "Synced public folder to content folder"
    else
      log_error "Failed to sync to content folder"
      exit 1
    fi
  else
    log_info "[DRY-RUN] Would sync: $PUBLIC_DIR/ → $CONTENT_DIR/"
  fi

  # Index 파일 생성
  log_section "Generating folder indexes"

  if [ "$DRY_RUN" = false ]; then
    generate_all_folder_indexes "$CONTENT_DIR"
    log_success "Generated folder indexes"
  else
    log_info "[DRY-RUN] Would generate folder indexes in: $CONTENT_DIR"
  fi

  # 최종 요약
  log_section "Sync Summary"

  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))

  log_info "Duration: ${DURATION}s"
  log_success "Sync completed successfully!"
}

# 스크립트 실행
main "$@"
