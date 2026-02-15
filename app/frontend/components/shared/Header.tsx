import { useState } from "react"
import { Link } from "@inertiajs/react"

export default function Header() {
  const [mobileOpen, setMobileOpen] = useState(false)

  return (
    <header className="sticky top-0 z-50 w-full" style={{ backgroundColor: "#FAFAFA" }}>
      <nav className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Logo */}
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2 group">
              <span className="text-3xl font-black tracking-tight" style={{ color: "#17233C" }}>
                CR4FTS
              </span>
            </Link>
          </div>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-4">
            <a
              href="#ventures"
              className="px-6 py-3 bg-white font-bold rounded-xl hover:shadow-xl transition-all"
              style={{ color: "#17233C" }}
            >
              Bets
            </a>
            <a
              href="#contact"
              className="px-6 py-3 bg-white font-bold rounded-xl hover:shadow-xl transition-all"
              style={{ color: "#17233C" }}
            >
              Contact
            </a>
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden p-2 rounded-lg hover:bg-black/5 transition-colors"
            style={{ color: "#17233C" }}
          >
            {mobileOpen ? (
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            ) : (
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            )}
          </button>
        </div>

        {/* Mobile Navigation Menu */}
        {mobileOpen && (
          <div className="md:hidden pb-4">
            <div className="flex flex-col gap-3">
              <a
                href="#ventures"
                onClick={() => setMobileOpen(false)}
                className="px-6 py-3 bg-white font-bold rounded-xl hover:shadow-xl transition-all text-center"
                style={{ color: "#17233C" }}
              >
                Bets
              </a>
              <a
                href="#contact"
                onClick={() => setMobileOpen(false)}
                className="px-6 py-3 bg-white font-bold rounded-xl hover:shadow-xl transition-all text-center"
                style={{ color: "#17233C" }}
              >
                Contact
              </a>
            </div>
          </div>
        )}
      </nav>
    </header>
  )
}
