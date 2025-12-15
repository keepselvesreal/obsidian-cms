#!/bin/bash

# 로그 디렉토리 설정
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/logs"

# logs 폴더 자동 생성
mkdir -p "$LOG_DIR"

# 로그 파일 경로 (형식: 25-12-15-1100.log)
TIMESTAMP=$(date +%y-%m-%d-%H%M)
LOG_FILE="$LOG_DIR/${TIMESTAMP}.log"
LOG_LATEST="$LOG_DIR/sync-latest.log"

# 로그 함수들
log_info() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a "$LOG_FILE" "$LOG_LATEST"
}

log_success() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $1" | tee -a "$LOG_FILE" "$LOG_LATEST"
}

log_warning() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1" | tee -a "$LOG_FILE" "$LOG_LATEST"
}

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ $1" | tee -a "$LOG_FILE" "$LOG_LATEST"
}

log_section() {
  echo "" | tee -a "$LOG_FILE" "$LOG_LATEST"
  echo "========== $1 ==========" | tee -a "$LOG_FILE" "$LOG_LATEST"
  echo "" | tee -a "$LOG_FILE" "$LOG_LATEST"
}
