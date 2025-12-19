#!/usr/bin/env node

import fs from 'fs'
import path from 'path'

const PUBLIC_DIR = path.join(process.cwd(), 'public')

/**
 * HTML에서 <article> 태그 내용 추출
 */
function extractArticleContent(html) {
  const match = html.match(/<article[^>]*>([\s\S]*?)<\/article>/)
  return match ? match[1] : null
}

/**
 * 한국어 HTML과 영어 HTML을 병합
 */
function mergeHtmlFiles(koreanPath, englishPath) {
  try {
    const koreanHtml = fs.readFileSync(koreanPath, 'utf8')
    const englishHtml = fs.readFileSync(englishPath, 'utf8')

    const englishContent = extractArticleContent(englishHtml)

    if (!englishContent) {
      console.error(`✗ 영어 콘텐츠 추출 실패: ${englishPath}`)
      return false
    }

    // 영어 콘텐츠를 HTML에 삽입
    const toggleButton = `<div class="lang-toggle" style="display: flex; gap: 8px; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 2px solid #e0e0e0;">
  <button class="lang-ko-btn" onclick="window.toggleLanguage('ko')" style="padding: 10px 16px; border: 2px solid #284b63; background: #284b63; color: white; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px;">한국어</button>
  <button class="lang-en-btn" onclick="window.toggleLanguage('en')" style="padding: 10px 16px; border: 2px solid #ccc; background: white; color: #333; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px;">English</button>
</div>`

    const mergedArticleContent = `
        ${toggleButton}
        <div class="lang-ko">
          ${extractArticleContent(koreanHtml)}
        </div>
        <div class="lang-en" style="display:none">
          ${englishContent}
        </div>`

    const mergedHtml = koreanHtml.replace(
      /<article[^>]*>([\s\S]*?)<\/article>/,
      `<article>${mergedArticleContent}</article>`
    )

    fs.writeFileSync(koreanPath, mergedHtml)
    console.log(`✓ 병합 완료: ${path.relative(PUBLIC_DIR, koreanPath)}`)
    return true
  } catch (error) {
    console.error(`✗ 병합 실패:`, error.message)
    return false
  }
}

/**
 * 모든 .en.html 파일을 찾아서 대응하는 .html과 병합
 */
function mergeAllBilingualFiles() {
  function findFiles(dir, pattern) {
    const files = []

    function walk(currentPath) {
      try {
        const entries = fs.readdirSync(currentPath)

        entries.forEach((entry) => {
          const fullPath = path.join(currentPath, entry)
          const stat = fs.statSync(fullPath)

          if (stat.isDirectory()) {
            walk(fullPath)
          } else if (entry.match(pattern)) {
            files.push(fullPath)
          }
        })
      } catch (err) {
        // 접근 권한 없음
      }
    }

    walk(dir)
    return files
  }

  // public/**/*.en.html 파일 찾기
  const enHtmlFiles = findFiles(PUBLIC_DIR, /\.en\.html$/)

  console.log(`찾은 영어 HTML 파일: ${enHtmlFiles.length}개\n`)

  for (const enHtmlPath of enHtmlFiles) {
    // 대응하는 .html 파일 경로
    const koreanHtmlPath = enHtmlPath.replace(/\.en\.html$/, '.html')

    if (!fs.existsSync(koreanHtmlPath)) {
      console.log(`⊘ 스킵: ${path.relative(PUBLIC_DIR, enHtmlPath)} (대응하는 .html 없음)`)
      continue
    }

    mergeHtmlFiles(koreanHtmlPath, enHtmlPath)
  }

  console.log('\n이중언어 병합 완료!')
}

mergeAllBilingualFiles()
