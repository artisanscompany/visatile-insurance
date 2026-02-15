import type { Venture } from "@/types"

export const ventures: Record<string, Venture & { subtitle: string; modalImage?: string }> = {
  hisdoctor: {
    id: "hisdoctor",
    title: "his.doctor",
    subtitle: "Health",
    description:
      "Men's health infrastructure barely exists—stigma keeps men silent, systems ignore their needs. Building telemedicine that removes shame from seeking care for sexual health, mental wellness, and general concerns for African men.",
    image: "/images/hisdoctor.jpg",
    modalImage: "/images/hisdoctor.jpg",
    status: "stealth",
  },
  visatile: {
    id: "visatile",
    title: "Visatile",
    subtitle: "Immigration",
    description:
      "Passport-disadvantaged Africans are trapped by broken visa systems that gatekeepers won't fix. Combining AI with expert visa officers to predict approval odds, optimize applications, and generate embassy-compliant documents—improving outcomes for travelers others have given up on.",
    image: "/images/visatile.jpg",
    status: "stealth",
  },
  build54: {
    id: "build54",
    title: "Build54",
    subtitle: "Education",
    description:
      "Exceptional African technical talent is invisible to credential-obsessed systems. Running competitions and hackathons across all 54 countries to discover builders through what they create—not where they studied or who they know.",
    image: "/images/build54.jpg",
    status: "stealth",
  },
  notarials: {
    id: "notarials",
    title: "Notarials",
    subtitle: "Legal",
    description:
      "Centuries-old notary monopolies make document verification slow, expensive, and inaccessible. Building digital infrastructure to make notarization instant and secure—removing gatekeepers from critical processes.",
    image: "/images/notarials.jpg",
    status: "stealth",
  },
  corppy: {
    id: "corppy",
    title: "Corppy",
    subtitle: "Compliance",
    description:
      "In stealth. Corporate compliance infrastructure too complex for incumbents to fix, too regulated for most to touch.",
    image: "/images/corppy.jpg",
    status: "stealth",
  },
  repoless: {
    id: "repoless",
    title: "Repoless",
    subtitle: "Developer Tools",
    description:
      "In stealth. Developer collaboration tools optimized for legacy workflows, not how exceptional teams actually work.",
    image: "/images/repoless.jpg",
    status: "stealth",
  },
  recordness: {
    id: "recordness",
    title: "Recordness",
    subtitle: "Enterprise",
    description:
      "In stealth. Organizational knowledge loss that scales with growth—a problem everyone acknowledges, few attempt to solve.",
    image: "/images/recordness.jpg",
    status: "stealth",
  },
  clauseless: {
    id: "clauseless",
    title: "Clauseless",
    subtitle: "Contracts",
    description:
      "In stealth. Legal processes locked behind cost and complexity—gatekeeping that preserves incumbents, not justice.",
    image: "/images/clauseless.jpg",
    status: "stealth",
  },
  hospiceble: {
    id: "hospiceble",
    title: "Hospiceble",
    subtitle: "Palliative Care",
    description:
      "In stealth. End-of-life care systems that fail families when dignity matters most—too hard, too sad, too ignored.",
    image: "/images/hospiceble.jpg",
    status: "stealth",
  },
}
