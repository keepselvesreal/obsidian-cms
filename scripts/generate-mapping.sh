#!/bin/bash

# generate-mapping.sh
# 책 폴더의 한국어 요약본과 영어 요약본을 매칭하여 mapping.json 생성

if [ $# -ne 1 ]; then
    echo "사용법: $0 <책_폴더_경로>"
    echo "예: $0 /path/to/books/AI-2026-트렌드활용백과"
    exit 1
fi

SOURCE_DIR="$1"
OUTPUT_FILE="$SOURCE_DIR/mapping.json"

# 소스 폴더 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo "오류: 소스 폴더가 없습니다: $SOURCE_DIR"
    exit 1
fi

# ============================================================
# 한국어 파일 목록에서 숫자 추출 및 영어 파일 매칭
# ============================================================

declare -A mappings

# 한국어 요약 파일 처리
while IFS= read -r ko_file; do
    if [ -z "$ko_file" ]; then
        continue
    fi

    ko_name=$(basename "$ko_file")

    # 숫자 추출 (예: 요약-05장-... → 05)
    chapter_num=$(echo "$ko_name" | grep -oP '(?<=-)\d+(?=장)' | head -1)

    if [ -z "$chapter_num" ]; then
        continue
    fi

    # 영어 파일 찾기 (summary-chXX-*.md)
    en_file=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name "summary-ch${chapter_num}-*" | head -1)

    if [ -z "$en_file" ]; then
        echo "경고: $ko_name과 매칭되는 영어 파일을 찾을 수 없습니다"
        continue
    fi

    en_name=$(basename "$en_file")

    # 매핑 저장
    mappings["$ko_name"]="$en_name"

done < <(find "$SOURCE_DIR" -maxdepth 1 -type f -name "요약*" | sort)

# ============================================================
# mapping.json 생성
# ============================================================

if [ ${#mappings[@]} -eq 0 ]; then
    echo "경고: 매칭된 파일이 없습니다"
    exit 1
fi

{
    echo "["

    first=true
    for ko_name in $(echo "${!mappings[@]}" | tr ' ' '\n' | sort); do
        en_name="${mappings[$ko_name]}"

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        printf '  {\n'
        printf '    "ko": "%s",\n' "$ko_name"
        printf '    "en": "%s"\n' "$en_name"
        printf '  }'
    done

    echo ""
    echo "]"
} > "$OUTPUT_FILE"

echo "✓ 매핑 파일 생성 완료: $OUTPUT_FILE"
echo "매핑 항목: ${#mappings[@]}개"
