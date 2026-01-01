import fs from 'fs-extra';
import path from 'path';

console.log('📦 빌드 결과 병합 시작...\n');

const baseDir = process.cwd();
const publicDir = path.join(baseDir, 'public');
const publicKoDir = path.join(baseDir, 'public-ko');
const publicEnDir = path.join(baseDir, 'public-en');

// public 디렉토리 초기화
if (fs.existsSync(publicDir)) {
  fs.removeSync(publicDir);
}
fs.ensureDirSync(publicDir);

// ko, en 폴더 복사 (attachments 제외)
['ko', 'en'].forEach(lang => {
  const src = path.join(baseDir, `public-${lang}`);
  const dest = path.join(publicDir, lang);

  if (!fs.existsSync(src)) {
    console.warn(`⚠️  ${src} 디렉토리를 찾을 수 없습니다`);
    return;
  }

  fs.ensureDirSync(dest);

  // attachments 제외하고 복사
  fs.readdirSync(src).forEach(file => {
    if (file !== 'attachments') {
      const srcPath = path.join(src, file);
      const destPath = path.join(dest, file);
      fs.copySync(srcPath, destPath, { overwrite: true });
    }
  });

  console.log(`✓ ${lang} 폴더 복사 완료`);
});

// attachments는 한 번만 복사 (공유 폴더)
const attachmentsSrc = path.join(publicKoDir, 'attachments');
const attachmentsDest = path.join(publicDir, 'attachments');

if (fs.existsSync(attachmentsSrc)) {
  fs.copySync(attachmentsSrc, attachmentsDest, { overwrite: true });
  console.log('✓ attachments 공유 폴더 복사 완료');
}

// 빌드 결과 폴더 정리
if (fs.existsSync(publicKoDir)) {
  fs.removeSync(publicKoDir);
}
if (fs.existsSync(publicEnDir)) {
  fs.removeSync(publicEnDir);
}

console.log('✓ 임시 빌드 폴더 정리 완료');
console.log('✓ 병합 완료!\n');
