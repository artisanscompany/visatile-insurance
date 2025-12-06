import { Controller } from "@hotwired/stimulus"

// Typewriter effect controller
// Animates text character-by-character to simulate typing
export default class extends Controller {
  static targets = ["title", "subtitle", "body"]
  static values = {
    speed: { type: Number, default: 50 },
    titleDelay: { type: Number, default: 500 },
    subtitleDelay: { type: Number, default: 1000 },
    bodyDelay: { type: Number, default: 1500 }
  }

  connect() {
    this.#animateSequence()
  }

  async #animateSequence() {
    if (this.hasTitleTarget) {
      await this.#delay(this.titleDelayValue)
      await this.#typeElement(this.titleTarget)
    }

    if (this.hasSubtitleTarget) {
      await this.#delay(this.subtitleDelayValue)
      await this.#typeElement(this.subtitleTarget)
    }

    if (this.hasBodyTarget) {
      await this.#delay(this.bodyDelayValue)
      await this.#typeElement(this.bodyTarget)
    }
  }

  async #typeElement(element) {
    const originalText = element.textContent
    element.textContent = ""
    element.classList.add("typewriter-cursor")

    for (const char of originalText) {
      element.textContent += char
      await this.#delay(this.speedValue)
    }

    element.classList.remove("typewriter-cursor")
  }

  #delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
