import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "modalImage", "modalTitle", "modalDescription"]

  connect() {
    console.log('Portfolio controller connected!')
    console.log('Modal target:', this.hasModalTarget)
    console.log('Modal element:', this.modalTarget)

    // Venture data
    this.ventures = {
      hisdoctor: {
        title: 'his.doctor',
        description: 'The safe space for men to address health concerns. Telemedicine platform providing discreet access to licensed doctors for sexual health, mental wellness, and general care across East Africa. Man up. Check up.',
        image: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1200&h=1200&fit=crop'
      },
      visatile: {
        title: 'Visatile',
        description: 'AI-powered immigration copilot achieving 94% visa approval rates for African travelers. Combining Stampy AI with expert visa officers to predict approval odds, generate embassy-compliant documents, and eliminate rejection anxiety.',
        image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&h=800&fit=crop'
      },
      build54: {
        title: 'Build54',
        description: 'Finding Africa\'s hidden STEM talents through technical competitions. Hackathons, olympiads, and challenges across all 54 countries—discovering exceptional builders through what they create, not credentials.',
        image: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&h=800&fit=crop'
      },
      notarials: {
        title: 'Notarials',
        description: 'Modern notary services reimagined for the digital age. Streamlining document verification and notarization with technology-first approach.',
        image: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800&h=800&fit=crop'
      },
      corppy: {
        title: 'Corppy',
        description: 'Stealth mode. Building infrastructure for the next generation of corporate operations.',
        image: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&h=800&fit=crop'
      },
      repoless: {
        title: 'Repoless',
        description: 'Stealth mode. Rethinking how teams collaborate on technical work.',
        image: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=800&fit=crop'
      },
      recordness: {
        title: 'Recordness',
        description: 'Stealth mode. Building tools for knowledge management and documentation.',
        image: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800&h=800&fit=crop'
      },
      clauseless: {
        title: 'Clauseless',
        description: 'Stealth mode. Simplifying legal processes.',
        image: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&h=800&fit=crop'
      },
      hospiceble: {
        title: 'Hospiceble',
        description: 'Stealth mode. Improving end-of-life care.',
        image: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=800&fit=crop'
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
