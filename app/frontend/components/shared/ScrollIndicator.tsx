import { useEffect, useState } from "react"

const sections = [
  { id: "hero", label: "Top" },
  { id: "thesis", label: "Thesis" },
  { id: "ventures", label: "Ventures" },
  { id: "makerspace", label: "Makerspace" },
  { id: "convictions", label: "Convictions" },
  { id: "people", label: "People" },
  { id: "contact", label: "Contact" },
]

export default function ScrollIndicator() {
  const [active, setActive] = useState("hero")

  useEffect(() => {
    const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            setActive(entry.target.id)
          }
        }
      },
      { threshold: 0.3 }
    )

    for (const section of sections) {
      const el = document.getElementById(section.id)
      if (el) observer.observe(el)
    }

    return () => observer.disconnect()
  }, [])

  const handleClick = (id: string) => {
    const el = document.getElementById(id)
    if (el) {
      el.scrollIntoView({ behavior: "smooth" })
    }
  }

  return (
    <nav className="fixed right-6 top-1/2 -translate-y-1/2 hidden xl:flex flex-col gap-2 z-40">
      {sections.map((section) => (
        <button
          key={section.id}
          onClick={() => handleClick(section.id)}
          className={`text-xs text-right transition-colors cursor-pointer ${
            active === section.id
              ? "text-black font-medium"
              : "text-[#C8C8C8] hover:text-[#9B9B9B]"
          }`}
          title={section.label}
        >
          {section.label}
        </button>
      ))}
    </nav>
  )
}
