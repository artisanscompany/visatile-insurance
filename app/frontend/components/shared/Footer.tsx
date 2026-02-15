import { usePage } from "@inertiajs/react"
import type { SharedProps } from "@/types"

export default function Footer() {
  const { currentYear } = usePage<{ props: SharedProps }>().props as unknown as SharedProps

  return (
    <footer className="w-full" style={{ backgroundColor: "#FAFAFA" }}>
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-gray-600">
          <p>&copy; {currentYear} CR4FTS. All rights reserved.</p>
          <div className="flex gap-6">
            <a href="#privacy" className="hover:text-gray-900 transition-colors">
              Privacy
            </a>
            <a href="#terms" className="hover:text-gray-900 transition-colors">
              Terms
            </a>
            <a href="#contact" className="hover:text-gray-900 transition-colors">
              Contact
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
