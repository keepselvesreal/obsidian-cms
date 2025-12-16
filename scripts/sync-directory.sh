#!/bin/bash

set -euo pipefail

# 폴더 동기화 스크립트
# 환경변수로 받는 공통 설정:
#   SCRIPT_DIR, OBSIDIAN_VAULT, PUBLIC_DIR, DRY_RUN, AUTO_INCLUDE_LINKS, COPIED_FILES_TRACKER

# 라이브러리 로드
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/obsidian-image-extractor.sh"
source "$SCRIPT_DIR/lib/image-copier.sh"
source "$SCRIPT_DIR/lib/folder-syncer.sh"
source "$SCRIPT_DIR/lib/link-extractor.sh"
source "$SCRIPT_DIR/lib/link-resolver.sh"
source "$SCRIPT_DIR/lib/link-processor.sh"
source "$SCRIPT_DIR/lib/find-in-public.sh"
source "$SCRIPT_DIR/lib/link-updater.sh"

# 폴더 동기화 (linked 파일 + 이미지 + 링크 처리 포함)
sync_directory() {
  local source="$1"
  local dest="$2"
  local dest_attachments="$PUBLIC_DIR/attachments"

  log_section "Syncing Directory"

  # 1단계: 폴더 동기화
  if [ "$DRY_RUN" = false ]; then
    if ! sync_folder "$source" "$dest" "false"; then
      log_error "Failed to sync folder"
      return 1
    fi
    log_success "Folder synced successfully"
  else
    log_info "[DRY-RUN] Would sync folder to: $dest"
  fi

  # 2단계: 폴더 내 모든 .md 파일에서 linked 파일들 수집
  log_section "Checking for Linked Files in Folder"

  local all_linked_files=""
  local should_copy_linked_files=true

  if [ "$DRY_RUN" = false ]; then
    while IFS= read -r md_file; do
      if [ -z "$md_file" ]; then
        continue
      fi

      # 각 .md 파일의 linked 파일 수집
      local linked_files=$(collect_all_linked_files "$md_file" "$OBSIDIAN_VAULT" 2>/dev/null || true)
      if [ -n "$linked_files" ]; then
        all_linked_files=$(echo -e "$all_linked_files\n$linked_files" | sort -u | grep -v '^$')
      fi
    done < <(find "$dest" -type f -name "*.md")
  fi

  # 3단계: linked 파일 목록 표시 및 사용자 동의 확인
  if [ -n "$all_linked_files" ]; then
    log_info "Found linked files that will be copied:"

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
    log_info "No linked files found in folder"
  fi

  # 4단계: linked 파일들 복사
  if [ -n "$all_linked_files" ] && [ "$should_copy_linked_files" = true ] && [ "$DRY_RUN" = false ]; then
    log_section "Copying Linked Files from Folder"

    echo "$all_linked_files" | while read -r linked_file; do
      if [ -z "$linked_file" ]; then
        continue
      fi

      # 링크된 파일의 상대 경로 계산
      local linked_relative_path="${linked_file#$OBSIDIAN_VAULT/}"
      local linked_relative_path="${linked_relative_path#*/}"  # 첫 세그먼트 제거
      local linked_dest="$PUBLIC_DIR/$linked_relative_path"

      # 이미 복사된 파일이 아니면 복사
      if [ ! -f "$linked_dest" ]; then
        "$SCRIPT_DIR/sync-single-file.sh" "$linked_file" "$linked_dest"
      else
        log_info "Already exists: $(basename "$linked_file")"
      fi
    done
  fi

  # 5단계: 동기화된 폴더의 모든 .md 파일 처리 (이미지 및 링크)
  log_section "Processing Images and Links in Folder"

  if [ "$DRY_RUN" = false ]; then
    while IFS= read -r md_file; do
      if [ -z "$md_file" ]; then
        continue
      fi

      log_info "Processing: $md_file"

      # 이미지 추출 및 복사
      local images=$(extract_obsidian_images "$md_file")

      if [ -n "$images" ]; then
        # 이미지 복사
        local source_attachments="${SOURCE_ATTACHMENTS_DIR:-$OBSIDIAN_VAULT/resources/attachments}"
        if copy_multiple_images "$images" "$source_attachments" "$dest_attachments"; then
          log_success "Images copied for: $(basename "$md_file")"
        else
          log_error "Failed to copy images for: $(basename "$md_file")"
        fi
      fi

      # 링크 업데이트
      if update_links_in_file "$md_file" "$OBSIDIAN_VAULT" "$PUBLIC_DIR"; then
        log_success "Links updated for: $(basename "$md_file")"
      fi
    done < <(find "$dest" -type f -name "*.md")
  else
    log_info "[DRY-RUN] Would process images and links in all .md files"
  fi
}

# 메인
if [ $# -lt 2 ]; then
  echo "Usage: $0 <SOURCE_PATH> <DEST_PATH>"
  echo "Environment variables required: SCRIPT_DIR, OBSIDIAN_VAULT, PUBLIC_DIR, DRY_RUN, AUTO_INCLUDE_LINKS, COPIED_FILES_TRACKER"
  exit 1
fi

sync_directory "$1" "$2"
