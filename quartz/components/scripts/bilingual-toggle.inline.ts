// 이중언어 토글 기능
// SPA 네비게이션 이후에도 작동하도록 전역 함수로 정의

declare global {
  interface Window {
    toggleLanguage: (lang: string) => void
  }
}

// 토글 함수를 전역으로 정의
window.toggleLanguage = function(lang: string) {
  const koDiv = document.querySelector('.lang-ko') as HTMLElement
  const enDiv = document.querySelector('.lang-en') as HTMLElement
  const koBtn = document.querySelector('.lang-ko-btn') as HTMLElement
  const enBtn = document.querySelector('.lang-en-btn') as HTMLElement

  if (lang === 'ko') {
    if (koDiv) koDiv.style.display = 'block'
    if (enDiv) enDiv.style.display = 'none'
    if (koBtn) {
      koBtn.style.background = '#284b63'
      koBtn.style.color = 'white'
      koBtn.style.borderColor = '#284b63'
    }
    if (enBtn) {
      enBtn.style.background = 'white'
      enBtn.style.color = '#333'
      enBtn.style.borderColor = '#ccc'
    }
  } else {
    if (koDiv) koDiv.style.display = 'none'
    if (enDiv) enDiv.style.display = 'block'
    if (koBtn) {
      koBtn.style.background = 'white'
      koBtn.style.color = '#333'
      koBtn.style.borderColor = '#ccc'
    }
    if (enBtn) {
      enBtn.style.background = '#284b63'
      enBtn.style.color = 'white'
      enBtn.style.borderColor = '#284b63'
    }
  }

  localStorage.setItem('preferredLang', lang)
}

// 초기 언어 설정 (페이지 로드 시 및 SPA 네비게이션 시)
function initializeLanguage() {
  // 토글 버튼이 있는 페이지인지 확인
  const langToggle = document.querySelector('.lang-toggle')
  if (!langToggle) return

  const savedLang = localStorage.getItem('preferredLang') || 'ko'
  window.toggleLanguage(savedLang)
}

// 초기 로드 시 실행
document.addEventListener('DOMContentLoaded', initializeLanguage)

// SPA 네비게이션 후에도 실행
document.addEventListener('nav', initializeLanguage)
