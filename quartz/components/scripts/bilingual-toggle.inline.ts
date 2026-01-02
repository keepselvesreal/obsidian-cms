// 이중언어 페이지 이동
// 다른 도메인의 대응 언어 페이지로 이동
// frontmatter의 enVersion/koVersion 정보 활용

declare global {
  interface Window {
    toggleLanguage: (lang: string) => void
    pageMetadata?: {
      enVersion?: string
      koVersion?: string
    }
  }
}

/**
 * frontmatter 메타데이터에서 언어 버전 정보 추출
 */
function getLanguageVersions() {
  // script#page-metadata 태그에서 데이터 읽기
  const metaTag = document.querySelector('meta[name="page-versions"]')

  if (metaTag) {
    try {
      return JSON.parse(metaTag.getAttribute('content') || '{}')
    } catch (e) {
      console.warn('Failed to parse page metadata:', e)
      return {}
    }
  }

  return window.pageMetadata || {}
}

/**
 * 현재 페이지의 도메인과 경로를 기반으로 다른 언어 페이지로 이동
 */
window.toggleLanguage = function(lang: string) {
  const metadata = getLanguageVersions()
  const currentUrl = window.location
  const currentDomain = currentUrl.hostname
  const currentPath = currentUrl.pathname

  let newUrl = ''

  if (lang === 'en') {
    // 한국어 → 영어로 이동
    if (currentDomain.includes('ko')) {
      const enDomain = currentDomain.replace('ko', 'en')

      // frontmatter에서 영어 버전 파일명 추출
      if (metadata.enVersion) {
        const enFileName = metadata.enVersion
        // 한국어 파일명을 영문 파일명으로 교체
        const newPath = currentPath.replace(/[^/]+$/, enFileName)
        newUrl = `https://${enDomain}${newPath}`
      } else {
        // 파일명이 없으면 그냥 경로만 이동
        newUrl = `https://${enDomain}${currentPath}`
      }
    }
  } else if (lang === 'ko') {
    // 영어 → 한국어로 이동
    if (currentDomain.includes('en')) {
      const koDomain = currentDomain.replace('en', 'ko')

      // frontmatter에서 한국어 버전 파일명 추출
      if (metadata.koVersion) {
        const koFileName = metadata.koVersion
        // 영문 파일명을 한국어 파일명으로 교체
        const newPath = currentPath.replace(/[^/]+$/, koFileName)
        newUrl = `https://${koDomain}${newPath}`
      } else {
        // 파일명이 없으면 그냥 경로만 이동
        newUrl = `https://${koDomain}${currentPath}`
      }
    }
  }

  if (newUrl) {
    window.location.href = newUrl
    localStorage.setItem('preferredLang', lang)
  }
}
