import { QuartzTransformerPlugin } from "../types"
import { Root as HTMLRoot } from "hast"
import { unified } from "unified"
import remarkParse from "remark-parse"
import remarkGfm from "remark-gfm"
import remarkRehype from "remark-rehype"
import { toHtml } from "hast-util-to-html"
import * as fs from "fs"
import * as path from "path"
import { QuartzPluginData } from "../vfile"

const contentDir = path.join(process.cwd(), "content")

/**
 * Frontmatter 제거 함수
 */
function removeFrontmatter(content: string): string {
  const frontmatterRegex = /^---[\s\S]*?---\s*/
  return content.replace(frontmatterRegex, "").trim()
}

/**
 * 마크다운을 HTML로 변환
 */
async function markdownToHtml(markdown: string): Promise<string> {
  const tree = unified()
    .use(remarkParse)
    .use(remarkGfm)
    .parse(markdown)

  const hast = unified()
    .use(remarkRehype)
    .runSync(tree)

  return toHtml(hast)
}

export const Bilingual: QuartzTransformerPlugin = () => ({
  name: "Bilingual",
  htmlPlugins() {
    return [
      () => {
        return async (tree: HTMLRoot, file) => {
          // .en.md 파일은 처리하지 않음 (무시됨)
          if (file.data.filePath?.endsWith(".en.md")) {
            return
          }

          // 한국어 .md 파일인 경우
          const filePath = file.data.filePath as string
          const koreanPath = path.join(contentDir, filePath)
          const enPath = koreanPath.replace(/\.md$/, ".en.md")

          // .en.md 파일이 존재하는지 확인
          if (!fs.existsSync(enPath)) {
            return
          }

          try {
            // 영어 마크다운 파일 로드
            let enMarkdown = fs.readFileSync(enPath, "utf-8")

            // Frontmatter 제거
            enMarkdown = removeFrontmatter(enMarkdown)

            // 마크다운→HTML 변환 (Quartz 표준 파이프라인)
            const enHtml = await markdownToHtml(enMarkdown)

            // frontmatter에 HTML 저장 (Component에서 접근)
            if (!file.data.frontmatter) {
              file.data.frontmatter = {}
            }
            (file.data.frontmatter as any).enContent = enHtml

            console.log(`✓ 이중언어 처리: ${filePath}`)
          } catch (error) {
            console.error(
              `✗ 이중언어 처리 실패 (${filePath}):`,
              (error as Error).message
            )
          }
        }
      },
    ]
  },
})

declare module "vfile" {
  interface DataMap {
    frontmatter: QuartzPluginData["frontmatter"] & {
      enContent?: string
    }
  }
}
