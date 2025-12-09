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
        description: 'Men\'s health infrastructure barely exists—stigma keeps men silent, systems ignore their needs. Building telemedicine that removes shame from seeking care for sexual health, mental wellness, and general concerns for African men.',
        image: '/assets/his-doctor.jpg'
      },
      visatile: {
        title: 'Visatile',
        description: 'Passport-disadvantaged Africans are trapped by broken visa systems that gatekeepers won\'t fix. Combining AI with expert visa officers to predict approval odds, optimize applications, and generate embassy-compliant documents—improving outcomes for travelers others have given up on.',
        image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&h=800&fit=crop'
      },
      build54: {
        title: 'Build54',
        description: 'Exceptional African technical talent is invisible to credential-obsessed systems. Running competitions and hackathons across all 54 countries to discover builders through what they create—not where they studied or who they know.',
        image: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&h=800&fit=crop'
      },
      notarials: {
        title: 'Notarials',
        description: 'Centuries-old notary monopolies make document verification slow, expensive, and inaccessible. Building digital infrastructure to make notarization instant and secure—removing gatekeepers from critical processes.',
        image: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800&h=800&fit=crop'
      },
      corppy: {
        title: 'Corppy',
        description: 'In stealth. Corporate compliance infrastructure too complex for incumbents to fix, too regulated for most to touch.',
        image: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&h=800&fit=crop'
      },
      repoless: {
        title: 'Repoless',
        description: 'In stealth. Developer collaboration tools optimized for legacy workflows, not how exceptional teams actually work.',
        image: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=800&fit=crop'
      },
      recordness: {
        title: 'Recordness',
        description: 'In stealth. Organizational knowledge loss that scales with growth—a problem everyone acknowledges, few attempt to solve.',
        image: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800&h=800&fit=crop'
      },
      clauseless: {
        title: 'Clauseless',
        description: 'In stealth. Legal processes locked behind cost and complexity—gatekeeping that preserves incumbents, not justice.',
        image: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&h=800&fit=crop'
      },
      hospiceble: {
        title: 'Hospiceble',
        description: 'In stealth. End-of-life care systems that fail families when dignity matters most—too hard, too sad, too ignored.',
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
    const customImage = event.currentTarget.dataset.ventureImage
    console.log('ventureId:', ventureId)
    console.log('customImage:', customImage)
    const venture = this.ventures[ventureId]
    console.log('venture:', venture)

    if (venture) {
      this.modalTitleTarget.textContent = venture.title
      this.modalDescriptionTarget.textContent = venture.description
      // Use custom image from data attribute if available, otherwise use default
      this.modalImageTarget.src = customImage || venture.image
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
