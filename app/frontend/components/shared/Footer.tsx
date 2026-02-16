import { usePage } from "@inertiajs/react"
import type { SharedProps } from "@/types"

export default function Footer() {
  const { currentYear } = usePage<{ props: SharedProps }>().props as unknown as SharedProps

  return (
    <footer className="w-full">
      <div className="max-w-4xl mx-auto px-6 md:px-12 py-12">
        <p className="text-xs text-[#C8C8C8]">
          &copy; {currentYear} CR4FTS
        </p>
      </div>
    </footer>
  )
}
