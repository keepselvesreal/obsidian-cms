#!/usr/bin/env node

import fs from 'fs';
import path from 'path';

const PUBLIC_DIR = path.join(process.cwd(), 'public');

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

function generateBilingual() {
  // *.en.html 파일 찾기
  const enFiles = findFiles(PUBLIC_DIR, /\.en\.html$/);

  console.log(`찾은 영어 파일: ${enFiles.length}개\n`);

  enFiles.forEach((fullEnPath) => {
    const enFilePath = path.relative(PUBLIC_DIR, fullEnPath);
    const baseFilePath = enFilePath.replace('.en.html', '.html');
    const fullBasePath = path.join(PUBLIC_DIR, baseFilePath);

    // 기본 HTML 파일 존재 확인
    if (!fs.existsSync(fullBasePath)) {
      console.log(`⊘ 스킵: ${enFilePath} (대응하는 .html 없음)`);
      return;
    }

    console.log(`병합: ${path.basename(baseFilePath)} + ${path.basename(enFilePath)}`);

    try {
      const baseHtml = fs.readFileSync(fullBasePath, 'utf8');
      const enHtml = fs.readFileSync(fullEnPath, 'utf8');

      const baseArticle = extractArticle(baseHtml);
      const enArticle = extractArticle(enHtml);

      if (!baseArticle || !enArticle) {
        console.error(`✗ 실패: ${baseFilePath} (article 태그 없음)`);
        return;
      }

      // 새로운 HTML 생성
      const headContent = extractHeadContent(baseHtml);
      const bodyAttrs = extractBodyAttrs(baseHtml);
      const bodyContent = baseHtml.match(/<body[^>]*>([\s\S]*?)<\/body>/);
      const innerBody = bodyContent ? bodyContent[1] : '';

      const mergedArticle = `
        <div class="lang-ko">
          ${baseArticle}
        </div>
        <div class="lang-en" style="display:none">
          ${enArticle}
        </div>`;

      const toggleButton = `
        <div class="lang-toggle" style="margin: 20px 0; display: flex; gap: 10px;">
          <button class="lang-btn lang-ko-btn" data-lang="ko" onclick="toggleLanguage(event, 'ko')" style="padding: 8px 16px; border: 1px solid #ccc; background: #284b63; color: white; border-radius: 4px; cursor: pointer; font-weight: 500;">한국어</button>
          <button class="lang-btn lang-en-btn" data-lang="en" onclick="toggleLanguage(event, 'en')" style="padding: 8px 16px; border: 1px solid #ccc; background: white; color: #333; border-radius: 4px; cursor: pointer; font-weight: 500;">English</button>
        </div>
        <script>
          (function() {
            const savedLang = localStorage.getItem('preferredLang') || 'ko';

            window.toggleLanguage = function(e, lang) {
              if (e) e.preventDefault();

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
                }
                if (enBtn) {
                  enBtn.style.background = 'white';
                  enBtn.style.color = '#333';
                }
              } else {
                if (koDiv) koDiv.style.display = 'none';
                if (enDiv) enDiv.style.display = 'block';
                if (koBtn) {
                  koBtn.style.background = 'white';
                  koBtn.style.color = '#333';
                }
                if (enBtn) {
                  enBtn.style.background = '#284b63';
                  enBtn.style.color = 'white';
                }
              }

              localStorage.setItem('preferredLang', lang);
            };

            // 초기 언어 설정
            window.toggleLanguage(null, savedLang);
          })();
        </script>`;

      const newBody = innerBody.replace(
        /<article[^>]*>[\s\S]*?<\/article>/,
        `<article>${mergedArticle}</article>${toggleButton}`
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

      fs.writeFileSync(fullBasePath, mergedHtml);
      console.log(`✓ 생성: ${baseFilePath}`);

      // .en.html 삭제
      fs.unlinkSync(fullEnPath);
      console.log(`✓ 삭제: ${path.basename(enFilePath)}`);
    } catch (error) {
      console.error(`✗ 에러 (${baseFilePath}):`, error.message);
    }
  });

  console.log('\n이중언어 페이지 생성 완료!');
}

generateBilingual();
