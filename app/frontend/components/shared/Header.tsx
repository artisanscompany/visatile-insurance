import { Link } from "@inertiajs/react"

export default function Header() {
  return (
    <header className="sticky top-0 z-50 w-full bg-white">
      <nav className="max-w-4xl mx-auto px-6 md:px-12">
        <div className="flex items-center h-12">
          <Link href="/" className="flex items-center">
            <img
              src="/icon.png"
              alt="CR4FTS"
              className="h-9 w-9 rounded-lg"
            />
          </Link>
        </div>
      </nav>
    </header>
  )
}
