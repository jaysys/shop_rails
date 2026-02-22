import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "input", "button"]

  connect() {
    this.boundOutsideClick = this.handleOutsideClick.bind(this)
    this.boundEsc = this.handleEsc.bind(this)
    document.addEventListener("click", this.boundOutsideClick)
    document.addEventListener("keydown", this.boundEsc)
  }

  disconnect() {
    document.removeEventListener("click", this.boundOutsideClick)
    document.removeEventListener("keydown", this.boundEsc)
  }

  toggle(event) {
    event.preventDefault()
    if (this.opened()) {
      this.close()
      return
    }
    this.open()
  }

  open() {
    if (this.opened()) return
    this.panelTarget.classList.remove("hidden")
    this.inputTarget?.focus()
    this.inputTarget?.select()
  }

  close(event = null) {
    event?.preventDefault()
    if (!this.opened()) return
    this.panelTarget.classList.add("hidden")
  }

  handleOutsideClick(event) {
    if (!this.opened()) return
    if (this.element.contains(event.target)) return
    this.close()
  }

  handleEsc(event) {
    if (event.key !== "Escape") return
    this.close()
  }

  opened() {
    return !this.panelTarget.classList.contains("hidden")
  }
}
