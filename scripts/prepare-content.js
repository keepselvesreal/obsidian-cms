import fs from 'fs-extra';
import path from 'path';

const lang = process.env.NODE_LANG || 'en';
const baseDir = process.cwd();
const contentDir = path.join(baseDir, 'content');
const langContentDir = path.join(baseDir, 'content', lang);
const attachmentsDir = path.join(baseDir, 'content', 'attachments');

// 임시 빌드용 content 폴더 준비
const tempContentDir = path.join(baseDir, '.content-temp');

console.log(`📝 준비 중... (언어: ${lang})\n`);

// 이전 임시 폴더 제거
if (fs.existsSync(tempContentDir)) {
  fs.removeSync(tempContentDir);
}

// 임시 폴더 생성
fs.ensureDirSync(tempContentDir);

// lang 폴더의 내용을 임시 폴더로 복사
if (fs.existsSync(langContentDir)) {
  fs.readdirSync(langContentDir).forEach(item => {
    const srcPath = path.join(langContentDir, item);
    const destPath = path.join(tempContentDir, item);
    fs.copySync(srcPath, destPath, { overwrite: true });
  });
  console.log(`✓ content/${lang} 폴더 내용을 .content-temp로 복사 완료`);
}

// attachments 심볼릭 링크
const tempAttachmentsDir = path.join(tempContentDir, 'attachments');
if (!fs.existsSync(tempAttachmentsDir) && fs.existsSync(attachmentsDir)) {
  // Windows에서는 심볼릭 링크가 문제가 될 수 있으므로 복사 사용
  fs.copySync(attachmentsDir, tempAttachmentsDir, { overwrite: true });
  console.log(`✓ attachments 폴더 복사 완료`);
}

// .content-temp를 content로 교체
const contentBackup = path.join(baseDir, '.content-backup');
if (fs.existsSync(contentDir)) {
  if (fs.existsSync(contentBackup)) {
    fs.removeSync(contentBackup);
  }
  fs.moveSync(contentDir, contentBackup, { overwrite: true });
}

fs.moveSync(tempContentDir, contentDir, { overwrite: true });

console.log('✓ 준비 완료!\n');
