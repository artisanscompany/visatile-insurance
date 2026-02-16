const team = [
  {
    name: "Usman Sotunde",
    role: "Partner",
    email: "usman@cr4fts.com",
    image: "/team/usman.jpg",
  },
  {
    name: "Abdulwaheed Yusuf",
    role: "Partner",
    email: "waheed@cr4fts.com",
    image: "/team/waheed.jpg",
  },
  {
    name: "Amara Okonkwo",
    role: "Engineering",
    image: "/team/amara.jpg",
  },
  {
    name: "Kofi Mensah",
    role: "Operations",
    image: "/team/kofi.jpg",
  },
  {
    name: "Fatima Bello",
    role: "Investments",
    image: "/team/fatima.jpg",
  },
  {
    name: "Daniel Kamau",
    role: "Makerspace Lead",
    image: "/team/daniel.jpg",
  },
  {
    name: "Zainab Mwangi",
    role: "Community",
    image: "/team/zainab.jpg",
  },
]

export default function Team() {
  return (
    <div id="people" className="py-12 md:py-16">
      <div className="mb-4">
        <h2 className="text-lg font-bold text-black">People</h2>
        <p className="text-sm text-[#9B9B9B]">Who we are</p>
      </div>

      <div className="space-y-3">
        {team.map((member) => (
          <div key={member.name} className="flex items-center gap-3 group">
            <img
              src={member.image}
              alt={member.name}
              className="w-8 h-8 rounded-full object-cover bg-[#E3E2DE]"
            />
            <div className="flex items-center gap-2">
              <span className="text-base font-semibold text-black">
                {member.name}
              </span>
              <span className="text-sm text-[#9B9B9B]">{member.role}</span>
            </div>
            {member.email && (
              <a
                href={`mailto:${member.email}`}
                className="text-[#C8C8C8] hover:text-black transition-colors opacity-0 group-hover:opacity-100"
              >
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </a>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
