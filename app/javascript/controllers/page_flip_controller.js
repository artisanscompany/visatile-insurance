import { Controller } from "@hotwired/stimulus"

// Page flip animation controller
// Provides smooth page-turning effect when navigating
export default class extends Controller {
  connect() {
    this.#setupTurboTransitions()
  }

  #setupTurboTransitions() {
    document.addEventListener("turbo:before-render", this.#handleBeforeRender)
    document.addEventListener("turbo:render", this.#handleRender)
  }

  disconnect() {
    document.removeEventListener("turbo:before-render", this.#handleBeforeRender)
    document.removeEventListener("turbo:render", this.#handleRender)
  }

  #handleBeforeRender = (event) => {
    const body = document.querySelector("main")
    if (body) {
      body.classList.add("page-flip-out")
    }
  }

  #handleRender = (event) => {
    const body = document.querySelector("main")
    if (body) {
      body.classList.add("page-flip-in")

      setTimeout(() => {
        body.classList.remove("page-flip-out", "page-flip-in")
      }, 600)
    }
  }
}
