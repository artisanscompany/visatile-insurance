import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content", "icon"]

  toggle(event) {
    const button = event.currentTarget
    const accordionItem = button.parentElement
    const content = accordionItem.querySelector('[data-faq-target="content"]')
    const icon = accordionItem.querySelector('[data-faq-target="icon"]')

    // Close all other items and restore their rotation
    this.buttonTargets.forEach((otherButton) => {
      if (otherButton !== button) {
        const otherItem = otherButton.parentElement
        const otherContent = otherItem.querySelector('[data-faq-target="content"]')
        const otherIcon = otherItem.querySelector('[data-faq-target="icon"]')

        otherContent.classList.add('hidden')
        otherIcon.style.transform = 'rotate(0deg)'
        // Restore original rotation for closed items
        otherItem.style.transform = ''
      }
    })

    // Toggle current item
    if (content.classList.contains('hidden')) {
      content.classList.remove('hidden')
      icon.style.transform = 'rotate(180deg)'
      // Straighten the opened accordion item
      accordionItem.style.transform = 'rotate(0deg)'
    } else {
      content.classList.add('hidden')
      icon.style.transform = 'rotate(0deg)'
      // Restore original rotation when closing
      accordionItem.style.transform = ''
    }
  }
}
