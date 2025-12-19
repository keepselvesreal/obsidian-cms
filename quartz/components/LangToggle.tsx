// @ts-ignore
import langToggleScript from "./scripts/langtoggle.inline"
import styles from "./styles/langtoggle.scss"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

const LangToggle: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
  return (
    <div class={classNames(displayClass, "lang-toggle")}>
      <button class="lang-btn lang-btn-ko active" data-lang="ko" aria-label="한국어">
        한국어
      </button>
      <button class="lang-btn lang-btn-en" data-lang="en" aria-label="English">
        English
      </button>
    </div>
  )
}

LangToggle.beforeDOMLoaded = langToggleScript
LangToggle.css = styles

export default (() => LangToggle) satisfies QuartzComponentConstructor
