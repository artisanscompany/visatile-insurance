import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "menuIcon", "closeIcon"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.menuIconTarget.classList.toggle("hidden")
    this.closeIconTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.menuIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }
}
