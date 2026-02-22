import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 2600 }
  }

  connect() {
    requestAnimationFrame(() => this.element.classList.add("show"))

    this.hideTimer = setTimeout(() => {
      this.element.classList.remove("show")
      this.element.classList.add("hide")
    }, this.delayValue)

    this.removeTimer = setTimeout(() => {
      this.element.remove()
    }, this.delayValue + 380)
  }

  disconnect() {
    clearTimeout(this.hideTimer)
    clearTimeout(this.removeTimer)
  }
}
