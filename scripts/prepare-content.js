import fs from 'fs-extra';
import path from 'path';

const lang = process.env.NODE_LANG || 'en';
const baseDir = process.cwd();
const contentDir = path.join(baseDir, 'content');
const langContentDir = path.join(baseDir, 'content', lang);
const attachmentsDir = path.join(baseDir, 'content', 'attachments');

console.log(`📝 준비 중... (언어: ${lang})\n`);

// content 디렉토리 초기화 (ko, en, attachments 제외)
if (fs.existsSync(contentDir)) {
  const itemsToKeep = new Set([lang, 'attachments', 'ko', 'en']);
  fs.readdirSync(contentDir).forEach(item => {
    if (!itemsToKeep.has(item)) {
      fs.removeSync(path.join(contentDir, item));
    }
  });
}

// lang 폴더의 내용을 content로 복사
if (fs.existsSync(langContentDir)) {
  fs.readdirSync(langContentDir).forEach(item => {
    const srcPath = path.join(langContentDir, item);
    const destPath = path.join(contentDir, item);

    if (!fs.existsSync(destPath)) {
      fs.copySync(srcPath, destPath, { overwrite: true });
    }
  });
  console.log(`✓ content/${lang} 폴더 내용을 content로 복사 완료`);
}

// attachments 복사 (공유)
if (fs.existsSync(attachmentsDir)) {
  const contentAttachmentsDir = path.join(contentDir, 'attachments');
  if (!fs.existsSync(contentAttachmentsDir)) {
    fs.copySync(attachmentsDir, contentAttachmentsDir, { overwrite: true });
    console.log(`✓ attachments 폴더 복사 완료`);
  }
}

console.log('✓ 준비 완료!\n');
