import { ComponentChildren } from "preact"
import { htmlToJsx } from "../../util/jsx"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "../types"

const ArticleWithLanguageToggle: QuartzComponent = ({
  fileData,
  tree,
}: QuartzComponentProps) => {
  const content = htmlToJsx(fileData.filePath!, tree) as ComponentChildren
  const classes: string[] = fileData.frontmatter?.cssclasses ?? []
  const classString = ["popover-hint", ...classes].join(" ")

  // 언어 버전 정보 확인 (frontmatter에서)
  const enVersion = fileData.frontmatter?.enVersion as string | undefined
  const koVersion = fileData.frontmatter?.koVersion as string | undefined
  const hasLanguageVersion = !!(enVersion || koVersion)

  // 현재 페이지가 영어인지 확인
  // 도메인 기반으로 감지
  const isEnglish = typeof window !== 'undefined' ? window.location.hostname.includes('en') : false

  return (
    <article class={classString}>
      {/* 토글 버튼 - 언어 버전이 있을 때만 표시 */}
      {hasLanguageVersion && (
        <div
          class="lang-toggle"
          style="display: flex; gap: 8px; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 2px solid #e0e0e0; justify-content: flex-end;"
        >
          {isEnglish ? (
            // -en.md 파일: 한국어 버튼만 표시
            <button
              class="lang-ko-btn"
              {...({ onclick: "window.toggleLanguage('ko')" } as any)}
              style="display: inline-block; padding: 10px 16px; border: 2px solid #284b63; background: #284b63; color: white; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px; text-decoration: none; min-width: 100px; text-align: center; line-height: 1.2; height: 44px; display: flex; align-items: center; justify-content: center;"
            >
              한국어
            </button>
          ) : (
            // 일반 .md 파일: English 버튼만 표시
            <button
              class="lang-en-btn"
              {...({ onclick: "window.toggleLanguage('en')" } as any)}
              style="display: inline-block; padding: 10px 16px; border: 2px solid #284b63; background: #284b63; color: white; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px; text-decoration: none; min-width: 100px; text-align: center; line-height: 1.2; height: 44px; display: flex; align-items: center; justify-content: center;"
            >
              English
            </button>
          )}
        </div>
      )}

      {/* 콘텐츠 */}
      {content}
    </article>
  )
}

export default (() => ArticleWithLanguageToggle) satisfies QuartzComponentConstructor
