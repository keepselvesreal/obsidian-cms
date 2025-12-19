// Language toggle functionality
export default () => {
  if (!document.querySelector('.lang-toggle')) return

  const toggleButtons = document.querySelectorAll('.lang-btn')
  const currentPath = window.location.pathname.replace(/\.en$/, '')

  // Load and parse language file
  const loadLanguageVersion = async (lang: string) => {
    try {
      const url = lang === 'en' ? currentPath + '.en' : currentPath

      const res = await fetch(url)
      if (!res.ok) throw new Error(`HTTP ${res.status}`)

      const html = await res.text()
      const parser = new DOMParser()
      const doc = parser.parseFromString(html, 'text/html')

      const article = doc.querySelector('article')
      if (article) {
        const currentArticle = document.querySelector('article')
        if (currentArticle) {
          currentArticle.innerHTML = article.innerHTML
        }
      }

      localStorage.setItem('preferredLang', lang)
    } catch (err) {
      console.error('Language switch failed:', err)
    }
  }

  // Attach click handlers
  toggleButtons.forEach((button) => {
    button.addEventListener('click', (e: Event) => {
      e.preventDefault()
      const lang = (button as HTMLElement).getAttribute('data-lang')
      if (lang) {
        loadLanguageVersion(lang)
        toggleButtons.forEach((b) => b.classList.remove('active'))
        button.classList.add('active')
      }
    })
  })

  // Set initial button state
  const savedLang = localStorage.getItem('preferredLang') || 'ko'
  const activeBtn = document.querySelector(`.lang-btn[data-lang="${savedLang}"]`)
  if (activeBtn) {
    activeBtn.classList.add('active')
  }
}
