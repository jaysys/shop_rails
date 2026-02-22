import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.reposition = this.reposition.bind(this)
    this.reposition()
    window.addEventListener("resize", this.reposition)
  }

  disconnect() {
    window.removeEventListener("resize", this.reposition)
  }

  reposition() {
    const actions = document.querySelector(".header-actions")
    const header = document.querySelector(".site-header")

    if (actions) {
      const rect = actions.getBoundingClientRect()
      const top = Math.max(8, rect.bottom + 6)
      const right = Math.max(8, window.innerWidth - rect.right)
      this.element.style.top = `${top}px`
      this.element.style.right = `${right}px`
      this.element.style.left = "auto"
      return
    }

    if (header) {
      const rect = header.getBoundingClientRect()
      this.element.style.top = `${Math.max(8, rect.bottom + 6)}px`
      this.element.style.right = "12px"
      this.element.style.left = "auto"
    }
  }
}
