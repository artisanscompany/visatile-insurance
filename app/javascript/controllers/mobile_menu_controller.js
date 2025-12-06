import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay", "openButton", "closeButton"]

  connect() {
    // Close menu on ESC key
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  open() {
    this.menuTarget.classList.remove("translate-x-full")
    this.menuTarget.classList.add("translate-x-0")
    this.overlayTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"

    // Focus first link for accessibility
    const firstLink = this.menuTarget.querySelector("a")
    if (firstLink) {
      setTimeout(() => firstLink.focus(), 100)
    }
  }

  close() {
    this.menuTarget.classList.remove("translate-x-0")
    this.menuTarget.classList.add("translate-x-full")
    this.overlayTarget.classList.add("hidden")
    document.body.style.overflow = ""

    // Return focus to open button
    if (this.hasOpenButtonTarget) {
      this.openButtonTarget.focus()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape" && !this.menuTarget.classList.contains("translate-x-full")) {
      this.close()
    }
  }

  closeOnOutsideClick(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}
