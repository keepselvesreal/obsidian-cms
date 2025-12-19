// 이중언어 페이지 이동
// 각 페이지가 독립적으로 존재하며, 버튼 클릭 시 다른 언어 페이지로 이동

declare global {
  interface Window {
    toggleLanguage: (lang: string) => void
  }
}

/**
 * 현재 페이지의 경로를 기반으로 다른 언어 페이지로 이동
 */
window.toggleLanguage = function(lang: string) {
  let currentPath = window.location.pathname

  // 마지막 / 제거
  if (currentPath.endsWith('/')) {
    currentPath = currentPath.slice(0, -1)
  }

  let newPath = currentPath

  if (lang === 'en') {
    // 한국어 → 영어로 이동 (.en 추가)
    if (!currentPath.endsWith('.en')) {
      newPath = currentPath + '.en'
    }
  } else {
    // 영어 → 한국어로 이동 (.en 제거)
    if (currentPath.endsWith('.en')) {
      newPath = currentPath.slice(0, -3) // '.en' 제거
    }
  }

  // 절대 경로로 이동
  window.location.href = newPath

  localStorage.setItem('preferredLang', lang)
}
