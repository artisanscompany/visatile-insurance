import type { Project } from "@/types"

interface PortfolioProps {
  projects: Project[]
}

export default function Portfolio({ projects }: PortfolioProps) {
  const totalSlots = 10
  const emptySlots = Math.max(0, totalSlots - projects.length)

  return (
    <div id="ventures" className="py-12 md:py-16 scroll-mt-14">
      <div className="mb-4">
        <h2 className="text-lg font-bold text-black">Ventures</h2>
        <p className="text-sm text-[#9B9B9B]">Bets we are making</p>
      </div>

      <div className="space-y-1">
        {projects.map((project) => (
          <div
            key={project.id}
            className="py-1.5 group flex items-center gap-2"
          >
            <span className="text-base font-semibold text-black group-hover:underline">
              {project.name}
            </span>
            {project.category && (
              <span className="text-sm text-[#9B9B9B]">
                {project.category}
              </span>
            )}
            {project.url && (
              <a
                href={project.url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[#6B6B6B] opacity-0 group-hover:opacity-100 transition-opacity"
              >
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </a>
            )}
          </div>
        ))}

        {Array.from({ length: emptySlots }).map((_, i) => (
          <div
            key={`empty-${i}`}
            className="py-1.5"
          >
            <span className="text-sm text-[#C8C8C8] italic">
              Coming soon
            </span>
          </div>
        ))}
      </div>
    </div>
  )
}
