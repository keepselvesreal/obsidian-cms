#!/bin/bash

set -euo pipefail

# 단일 파일 동기화 스크립트
# 환경변수로 받는 공통 설정:
#   SCRIPT_DIR, OBSIDIAN_VAULT, PUBLIC_DIR, DRY_RUN, AUTO_INCLUDE_LINKS, COPIED_FILES_TRACKER

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/obsidian-image-extractor.sh"
source "$SCRIPT_DIR/lib/image-copier.sh"
source "$SCRIPT_DIR/lib/file-syncer.sh"
source "$SCRIPT_DIR/lib/link-extractor.sh"
source "$SCRIPT_DIR/lib/link-resolver.sh"
source "$SCRIPT_DIR/lib/link-processor.sh"
source "$SCRIPT_DIR/lib/find-in-public.sh"
source "$SCRIPT_DIR/lib/link-updater.sh"

# 단일 파일 동기화 (이미지 + 링크 처리 포함)
sync_single_file() {
  local source="$1"
  local dest="$2"
  local dest_attachments="$PUBLIC_DIR/attachments"

  log_section "Processing Single File: $(basename "$source")"

  # 이미 복사된 파일인지 확인
  if grep -q "^$(basename "$source")$" "$COPIED_FILES_TRACKER" 2>/dev/null; then
    log_info "Already processed: $(basename "$source")"
    return 0
  fi

  # 복사 표시
  echo "$(basename "$source")" >> "$COPIED_FILES_TRACKER"

  # 1단계: Obsidian 이미지 추출
  log_info "Extracting images from file..."
  local images=$(extract_obsidian_images "$source")

  if [ -n "$images" ]; then
    # 2단계: 이미지를 public/attachments로 복사
    log_info "Copying images to public/attachments..."
    local source_attachments="${SOURCE_ATTACHMENTS_DIR:-$OBSIDIAN_VAULT/resources/attachments}"

    if [ "$DRY_RUN" = false ]; then
      if copy_multiple_images "$images" "$source_attachments" "$dest_attachments"; then
        log_success "Images copied successfully"
      else
        log_error "Failed to copy some images"
        return 1
      fi
    else
      log_info "[DRY-RUN] Would copy images to: $dest_attachments"
    fi
  else
    log_info "No images found in file"
  fi

  # 3단계: 링크 추출 및 사용자 동의 확인 (파일 복사 전)
  log_section "Checking for Linked Files"

  local all_linked_files=$(collect_all_linked_files "$source" "$OBSIDIAN_VAULT")
  local should_copy_linked_files=true

  if [ -n "$all_linked_files" ]; then
    log_info "Found linked files that will be copied:"

    # 링크 목록 표시
    echo "$all_linked_files" | while read -r linked_file; do
      log_info "  - $(basename "$linked_file")"
    done

    # --auto-include-links가 없으면 사용자에게 묻기
    if [ "$AUTO_INCLUDE_LINKS" = false ]; then
      echo ""
      read -p "이 파일들도 함께 복사하시겠습니까? (y/n): " user_input || user_input="n"

      if [[ "$user_input" != "y" && "$user_input" != "Y" ]]; then
        log_info "Skipping linked files copy"
        should_copy_linked_files=false
      fi
    fi

    if [ "$should_copy_linked_files" = true ]; then
      log_info "User approved: Will include linked files"
    fi
  else
    log_info "No linked files found"
  fi

  # 4단계: 주 파일 복사 (linked 파일 복사 여부와 무관하게)
  log_info "Copying file to public folder..."
  if [ "$DRY_RUN" = false ]; then
    if ! sync_file "$source" "$dest" "false"; then
      log_error "Failed to copy file"
      return 1
    fi
    log_success "File copied successfully"
  else
    log_info "[DRY-RUN] Would copy file to: $dest"
  fi

  # 5단계: 링크된 파일들 복사 (재귀)
  if [ -n "$all_linked_files" ] && [ "$should_copy_linked_files" = true ]; then
    log_section "Copying Linked Files"

    echo "$all_linked_files" | while read -r linked_file; do
      # 링크된 파일의 상대 경로 계산
      local linked_relative_path="${linked_file#$OBSIDIAN_VAULT/}"
      local linked_relative_path="${linked_relative_path#*/}"  # 첫 세그먼트 제거
      local linked_dest="$PUBLIC_DIR/$linked_relative_path"

      if [ "$DRY_RUN" = false ]; then
        "$SCRIPT_DIR/sync-single-file.sh" "$linked_file" "$linked_dest"
      else
        log_info "[DRY-RUN] Would sync linked file: $linked_file"
      fi
    done
  fi

  # 6단계: 링크 업데이트 (모든 linked 파일들이 public에 복사된 후)
  log_section "Updating Links"
  log_info "Updating links in copied file..."
  if [ "$DRY_RUN" = false ]; then
    if update_links_in_file "$dest" "$OBSIDIAN_VAULT" "$PUBLIC_DIR"; then
      log_success "Links updated successfully"
    else
      log_warning "Some links could not be updated"
    fi
  else
    log_info "[DRY-RUN] Would update links in: $dest"
  fi
}

# 메인
if [ $# -lt 2 ]; then
  echo "Usage: $0 <SOURCE_PATH> <DEST_PATH>"
  echo "Environment variables required: SCRIPT_DIR, OBSIDIAN_VAULT, PUBLIC_DIR, DRY_RUN, AUTO_INCLUDE_LINKS, COPIED_FILES_TRACKER"
  exit 1
fi

sync_single_file "$1" "$2"
