// Language toggle functionality
export default () => {
  const langBtns = document.querySelectorAll('.lang-btn')
  const savedLang = localStorage.getItem('preferredLang') || 'ko'

  // Set initial active button
  document.querySelector(`.lang-btn[data-lang="${savedLang}"]`)?.classList.add('active')

  langBtns.forEach(btn => {
    btn.addEventListener('click', async (e) => {
      e.preventDefault()
      const targetLang = (btn as HTMLElement).dataset.lang

      if (!targetLang) return

      // Remove active class from all buttons
      langBtns.forEach(b => b.classList.remove('active'))

      // Add active class to clicked button
      btn.classList.add('active')

      // Get current path without language suffix
      const currentPath = window.location.pathname
        .replace(/\.ko$/, '')
        .replace(/\.en$/, '')

      // Fetch the target language version
      try {
        const targetUrl = targetLang === 'ko'
          ? currentPath
          : currentPath + '.en'

        const response = await fetch(targetUrl)
        const html = await response.text()
        const parser = new DOMParser()
        const newDoc = parser.parseFromString(html, 'text/html')

        // Extract article content
        const newContent = newDoc.querySelector('article')
        const currentArticle = document.querySelector('article')

        if (newContent && currentArticle) {
          currentArticle.innerHTML = newContent.innerHTML
        }

        // Save user preference
        localStorage.setItem('preferredLang', targetLang)

        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' })
      } catch (error) {
        console.error('Failed to load language version:', error)
      }
    })
  })
}
