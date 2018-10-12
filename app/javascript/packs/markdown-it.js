import MarkdownIt from 'markdown-it'
import MarkdownItPlantUML from 'markdown-it-plantuml'

document.addEventListener('DOMContentLoaded', () => {
  let md = new MarkdownIt({
    html: true,
    breaks: true,
    linkify: true,
    langPrefix: 'language-'
  })

  md.use(MarkdownItPlantUML)
  ;[].forEach.call(document.querySelectorAll('.js-markdown-view'), e => {
    e.style.display = 'block'
    e.innerHTML = md.render(e.textContent)
  })
})
