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

  // 현재 페이지가 영어인지 확인
  const isEnglish = fileData.filePath?.endsWith(".en.md")

  return (
    <article class={classString}>
      {/* 토글 버튼 */}
      <div
        class="lang-toggle"
        style="display: flex; gap: 8px; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 2px solid #e0e0e0; justify-content: flex-end;"
      >
        <button
          class="lang-ko-btn"
          onclick="window.toggleLanguage('ko')"
          style={`display: inline-block; padding: 10px 16px; border: 2px solid #284b63; background: ${
            isEnglish ? "white" : "#284b63"
          }; color: ${isEnglish ? "#333" : "white"}; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px; border-color: ${
            isEnglish ? "#ccc" : "#284b63"
          }; text-decoration: none;`}
        >
          한국어
        </button>
        <button
          class="lang-en-btn"
          onclick="window.toggleLanguage('en')"
          style={`display: inline-block; padding: 10px 16px; border: 2px solid #284b63; background: ${
            isEnglish ? "#284b63" : "white"
          }; color: ${isEnglish ? "white" : "#333"}; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px; border-color: ${
            isEnglish ? "#284b63" : "#ccc"
          }; text-decoration: none;`}
        >
          English
        </button>
      </div>

      {/* 콘텐츠 */}
      {content}
    </article>
  )
}

export default (() => ArticleWithLanguageToggle) satisfies QuartzComponentConstructor
