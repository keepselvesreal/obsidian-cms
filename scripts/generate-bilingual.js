#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import remarkRehype from 'remark-rehype';
import { toHtml } from 'hast-util-to-html';

const PUBLIC_DIR = path.join(process.cwd(), 'public');
const CONTENT_DIR = path.join(process.cwd(), 'content');

// 재귀적으로 모든 파일 찾기
function findFiles(dir, pattern) {
  const files = [];

  function walk(currentPath) {
    try {
      const entries = fs.readdirSync(currentPath);

      entries.forEach((entry) => {
        const fullPath = path.join(currentPath, entry);
        const stat = fs.statSync(fullPath);

        if (stat.isDirectory()) {
          walk(fullPath);
        } else if (entry.match(pattern)) {
          files.push(fullPath);
        }
      });
    } catch (err) {
      // 접근 권한이 없는 폴더는 무시
    }
  }

  walk(dir);
  return files;
}

// 마크다운을 HTML로 변환
async function markdownToHtml(markdown) {
  const tree = unified()
    .use(remarkParse)
    .use(remarkGfm)
    .parse(markdown);

  const hast = unified()
    .use(remarkRehype)
    .runSync(tree);

  return toHtml(hast);
}

// 정규식으로 HTML 파싱
function extractArticle(html) {
  const match = html.match(/<article[^>]*>([\s\S]*?)<\/article>/);
  return match ? match[1] : null;
}

function extractHeadContent(html) {
  const match = html.match(/<head[^>]*>([\s\S]*?)<\/head>/);
  return match ? match[1] : '';
}

function extractBodyAttrs(html) {
  const match = html.match(/<body([^>]*)>/);
  return match ? match[1] : '';
}

async function generateBilingual() {
  // content/**/*.en.md 파일 찾기
  const enMdFiles = findFiles(CONTENT_DIR, /\.en\.md$/);

  console.log(`찾은 영어 마크다운 파일: ${enMdFiles.length}개\n`);

  for (const fullEnMdPath of enMdFiles) {
    const relativePath = path.relative(CONTENT_DIR, fullEnMdPath);
    const baseFileName = path.basename(fullEnMdPath, '.en.md');
    const dirName = path.dirname(relativePath);

    // 대응하는 public/**/*.html 찾기
    const publicHtmlPath = path.join(PUBLIC_DIR, dirName, `${baseFileName}.html`);

    if (!fs.existsSync(publicHtmlPath)) {
      console.log(`⊘ 스킵: ${relativePath} (대응하는 .html 없음)`);
      continue;
    }

    console.log(`병합: ${path.basename(publicHtmlPath)} + ${path.basename(fullEnMdPath)}`);

    try {
      const baseHtml = fs.readFileSync(publicHtmlPath, 'utf8');
      const enMarkdown = fs.readFileSync(fullEnMdPath, 'utf8');

      // 마크다운을 HTML로 변환
      const enHtml = await markdownToHtml(enMarkdown);

      const baseArticle = extractArticle(baseHtml);
      const enArticle = enHtml; // 변환된 HTML 전체 사용

      if (!baseArticle) {
        console.error(`✗ 실패: ${publicHtmlPath} (article 태그 없음)`);
        continue;
      }

      // 새로운 HTML 생성
      const headContent = extractHeadContent(baseHtml);
      const bodyAttrs = extractBodyAttrs(baseHtml);
      const bodyContent = baseHtml.match(/<body[^>]*>([\s\S]*?)<\/body>/);
      const innerBody = bodyContent ? bodyContent[1] : '';

      const toggleButton = `<div class="lang-toggle" style="display: flex; gap: 8px; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 2px solid #e0e0e0;">
  <button class="lang-ko-btn" onclick="toggleLanguage('ko')" style="padding: 10px 16px; border: 2px solid #284b63; background: #284b63; color: white; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px;">한국어</button>
  <button class="lang-en-btn" onclick="toggleLanguage('en')" style="padding: 10px 16px; border: 2px solid #ccc; background: white; color: #333; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px;">English</button>
</div>`;

      const mergedArticle = `
        ${toggleButton}
        <div class="lang-ko">
          ${baseArticle}
        </div>
        <div class="lang-en" style="display:none">
          ${enArticle}
        </div>`;

      const toggleScript = `<script>
        (function() {
          const savedLang = localStorage.getItem('preferredLang') || 'ko';

          window.toggleLanguage = function(lang) {
            const koDiv = document.querySelector('.lang-ko');
            const enDiv = document.querySelector('.lang-en');
            const koBtn = document.querySelector('.lang-ko-btn');
            const enBtn = document.querySelector('.lang-en-btn');

            if (lang === 'ko') {
              if (koDiv) koDiv.style.display = 'block';
              if (enDiv) enDiv.style.display = 'none';
              if (koBtn) {
                koBtn.style.background = '#284b63';
                koBtn.style.color = 'white';
                koBtn.style.borderColor = '#284b63';
              }
              if (enBtn) {
                enBtn.style.background = 'white';
                enBtn.style.color = '#333';
                enBtn.style.borderColor = '#ccc';
              }
            } else {
              if (koDiv) koDiv.style.display = 'none';
              if (enDiv) enDiv.style.display = 'block';
              if (koBtn) {
                koBtn.style.background = 'white';
                koBtn.style.color = '#333';
                koBtn.style.borderColor = '#ccc';
              }
              if (enBtn) {
                enBtn.style.background = '#284b63';
                enBtn.style.color = 'white';
                enBtn.style.borderColor = '#284b63';
              }
            }

            localStorage.setItem('preferredLang', lang);
          };

          // 초기 언어 설정
          window.toggleLanguage(savedLang);
        })();
      </script>`;

      const newBody = innerBody.replace(
        /<article[^>]*>[\s\S]*?<\/article>/,
        `<article>${mergedArticle}</article>${toggleScript}`
      );

      const mergedHtml = `<!DOCTYPE html>
<html>
<head>
${headContent}
</head>
<body${bodyAttrs}>
${newBody}
</body>
</html>`;

      fs.writeFileSync(publicHtmlPath, mergedHtml);
      console.log(`✓ 생성: ${path.relative(PUBLIC_DIR, publicHtmlPath)}`);
    } catch (error) {
      console.error(`✗ 에러 (${relativePath}):`, error.message);
    }
  }

  console.log('\n이중언어 페이지 생성 완료!');
}

generateBilingual().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
