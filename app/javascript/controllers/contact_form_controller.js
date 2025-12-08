import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "loading"]

  submit(event) {
    // Show loading state
    if (this.hasSubmitTarget && this.hasLoadingTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.value = "Sending..."
      this.loadingTarget.classList.remove("hidden")
    }
  }
}
