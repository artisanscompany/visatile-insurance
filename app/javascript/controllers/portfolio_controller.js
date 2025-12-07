import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "modalImage", "modalTitle", "modalDescription"]

  connect() {
    console.log('Portfolio controller connected!')
    console.log('Modal target:', this.hasModalTarget)
    console.log('Modal element:', this.modalTarget)

    // Venture data
    this.ventures = {
      dataflow: {
        title: 'DataFlow',
        description: 'Next-gen analytics platform for data-driven decisions. Transform your raw data into actionable insights with our powerful visualization and reporting tools.',
        image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1200&h=1200&fit=crop'
      },
      buildkit: {
        title: 'BuildKit',
        description: 'Developer tools that accelerate your development workflow. Build faster, deploy smarter, and ship with confidence.',
        image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=800&fit=crop'
      },
      teamsync: {
        title: 'TeamSync',
        description: 'Collaboration suite that brings your team together. Real-time communication, project management, and workflow automation in one place.',
        image: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&h=800&fit=crop'
      },
      marketedge: {
        title: 'MarketEdge',
        description: 'E-commerce platform designed for modern retailers. Sell anywhere, manage everything, grow your business.',
        image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=800&fit=crop'
      },
      cloudsync: {
        title: 'CloudSync',
        description: 'Cloud infrastructure management platform. Deploy, scale, and monitor your applications with ease.',
        image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&h=600&fit=crop'
      }
    }

    // Bind escape key handler
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.handleEscape)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscape)
  }

  openModal(event) {
    console.log('openModal called')
    const ventureId = event.currentTarget.dataset.venture
    console.log('ventureId:', ventureId)
    const venture = this.ventures[ventureId]
    console.log('venture:', venture)

    if (venture) {
      this.modalTitleTarget.textContent = venture.title
      this.modalDescriptionTarget.textContent = venture.description
      this.modalImageTarget.src = venture.image
      this.modalImageTarget.alt = venture.title

      this.modalTarget.classList.add('show')
      document.body.style.overflow = 'hidden'
      console.log('Modal opened')
    } else {
      console.error('Venture not found:', ventureId)
    }
  }

  closeModal() {
    this.modalTarget.classList.remove('show')
    document.body.style.overflow = ''
  }

  closeOnBackgroundClick(event) {
    if (event.target === this.modalTarget) {
      this.closeModal()
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape' && this.modalTarget.classList.contains('show')) {
      this.closeModal()
    }
  }
}
