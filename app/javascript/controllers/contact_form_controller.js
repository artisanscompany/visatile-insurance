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

  handleStart(event) {
    // Show loading state when Turbo starts submission
    if (this.hasSubmitTarget && this.hasLoadingTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.value = "Sending..."
      this.loadingTarget.classList.remove("hidden")
    }
  }

  handleSuccess(event) {
    // Check if the form submission was successful
    const detail = event.detail

    // Check if we have a successful response
    if (detail.fetchResponse) {
      const response = detail.fetchResponse

      if (response.succeeded) {
        // Hide the form
        const formContainer = document.getElementById("contact-form-container")
        if (formContainer) {
          formContainer.style.display = "none"
        }

        // Show success message
        const successMessage = document.getElementById("contact-success")
        if (successMessage) {
          successMessage.classList.remove("hidden")
          // Scroll to success message
          setTimeout(() => {
            successMessage.scrollIntoView({ behavior: "smooth", block: "center" })
          }, 100)
        }
      } else {
        // Reset button state on error
        this.resetForm()
      }
    }
  }

  resetForm() {
    if (this.hasSubmitTarget && this.hasLoadingTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.value = "Send Message"
      this.loadingTarget.classList.add("hidden")
    }
  }
}
