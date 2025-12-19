import { QuartzTransformerPlugin } from "../types"
import { Root as HTMLRoot, Root as MdastRoot } from "hast"
import { unified } from "unified"
import remarkParse from "remark-parse"
import remarkGfm from "remark-gfm"
import remarkRehype from "remark-rehype"
import { toHtml } from "hast-util-to-html"
import { visit } from "unist-util-visit"
import { toString } from "hast-util-to-string"
import Slugger from "github-slugger"
import * as fs from "fs"
import * as path from "path"
import { QuartzPluginData } from "../vfile"

const contentDir = path.join(process.cwd(), "content")

interface TocEntry {
  depth: number
  text: string
  slug: string
}

/**
 * Frontmatter 제거 함수
 */
function removeFrontmatter(content: string): string {
  const frontmatterRegex = /^---[\s\S]*?---\s*/
  return content.replace(frontmatterRegex, "").trim()
}

/**
 * HTML AST에서 목차 생성
 */
function extractTableOfContents(hast: HTMLRoot): TocEntry[] {
  const toc: TocEntry[] = []
  const slugger = new Slugger()

  visit(hast, "element", (node) => {
    if (node.tagName && /^h[1-6]$/.test(node.tagName)) {
      const depth = parseInt(node.tagName[1])
      const text = toString(node)
      toc.push({
        depth,
        text,
        slug: slugger.slug(text),
      })
    }
  })

  return toc
}

/**
 * 마크다운을 HTML과 목차로 변환
 */
async function markdownToHtmlWithToc(
  markdown: string
): Promise<{ html: string; toc: TocEntry[] }> {
  const mdast = unified()
    .use(remarkParse)
    .use(remarkGfm)
    .parse(markdown)

  const hast = unified()
    .use(remarkRehype)
    .runSync(mdast)

  const html = toHtml(hast)
  const toc = extractTableOfContents(hast as HTMLRoot)

  return { html, toc }
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

            // 마크다운→HTML + 목차 변환
            const { html: enHtml, toc: enToc } = await markdownToHtmlWithToc(enMarkdown)

            // frontmatter에 저장
            if (!file.data.frontmatter) {
              file.data.frontmatter = {}
            }
            (file.data.frontmatter as any).enContent = enHtml
            (file.data.frontmatter as any).enToc = enToc

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
      enToc?: TocEntry[]
    }
  }
}
