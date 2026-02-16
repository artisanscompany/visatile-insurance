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
        {projects.map((project) => {
          const isLive = !!project.url
          const Row = (
            <div className="py-1.5 group flex items-center gap-2">
              <span
                className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${
                  isLive ? "bg-emerald-400" : "bg-[#C8C8C8]"
                }`}
              />
              <span className="text-base font-semibold text-black group-hover:underline">
                {project.name}
              </span>
              {project.category && (
                <span className="text-sm text-[#9B9B9B]">
                  {project.category}
                </span>
              )}
              <span className="text-[#C8C8C8] opacity-0 group-hover:opacity-100 transition-opacity ml-auto">
                &rarr;
              </span>
            </div>
          )

          return project.url ? (
            <a
              key={project.id}
              href={project.url}
              target="_blank"
              rel="noopener noreferrer"
              className="block"
            >
              {Row}
            </a>
          ) : (
            <div key={project.id}>{Row}</div>
          )
        })}

        {Array.from({ length: emptySlots }).map((_, i) => (
          <div key={`empty-${i}`} className="py-1.5 flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full flex-shrink-0 bg-[#C8C8C8]" />
            <span className="text-sm text-[#C8C8C8] italic">
              Coming soon
            </span>
          </div>
        ))}
      </div>
    </div>
  )
}
