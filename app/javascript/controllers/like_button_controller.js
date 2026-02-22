import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "countLabel"]
  static values = {
    url: String,
    liked: Boolean,
    count: Number
  }

  connect() {
    this.render()
  }

  async toggle() {
    if (this.loading) return
    this.loading = true
    this.buttonTarget.disabled = true

    const method = this.likedValue ? "DELETE" : "POST"
    const token = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.urlValue, {
        method,
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": token
        },
        credentials: "same-origin"
      })

      if (!response.ok) throw new Error("like request failed")

      const payload = await response.json()
      this.likedValue = !!payload.liked
      this.countValue = Number(payload.like_count || 0)
      this.render()
    } catch (error) {
      console.error(error)
    } finally {
      this.loading = false
      this.buttonTarget.disabled = false
    }
  }

  render() {
    this.buttonTarget.textContent = this.likedValue ? "♥" : "♡"
    this.buttonTarget.classList.toggle("liked", this.likedValue)
    this.countLabelTarget.textContent = `좋아요 ${this.countValue}`
  }
}
