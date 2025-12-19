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

  // frontmatter에서 영어 콘텐츠 가져오기
  const enContent = (fileData.frontmatter as any)?.enContent as string | undefined

  return (
    <article class={classString}>
      {/* 토글 버튼 */}
      {enContent && (
        <div
          class="lang-toggle"
          style="display: flex; gap: 8px; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 2px solid #e0e0e0;"
        >
          <button
            class="lang-ko-btn"
            onclick="window.toggleLanguage('ko')"
            style="padding: 10px 16px; border: 2px solid #284b63; background: #284b63; color: white; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px;"
          >
            한국어
          </button>
          <button
            class="lang-en-btn"
            onclick="window.toggleLanguage('en')"
            style="padding: 10px 16px; border: 2px solid #ccc; background: white; color: #333; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px;"
          >
            English
          </button>
        </div>
      )}

      {/* 한국어 콘텐츠 */}
      <div class="lang-ko">{content}</div>

      {/* 영어 콘텐츠 */}
      {enContent && (
        <div
          class="lang-en"
          style="display: none"
          dangerouslySetInnerHTML={{ __html: enContent }}
        />
      )}
    </article>
  )
}

export default (() => ArticleWithLanguageToggle) satisfies QuartzComponentConstructor
