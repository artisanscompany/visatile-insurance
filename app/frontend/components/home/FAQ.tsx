import { useState } from "react"
import type { FaqItem } from "@/types"

const fallbackFaqs = [
  {
    question: "Don't chase trends",
    answer:
      "No tourist founders. No optimizing for optics over outcomes. We won't touch a deal just because the market is hot or the deck is pretty. If you're building something safe that everyone already agrees on, we're the wrong partner.",
  },
  {
    question: "Capital has blind spots",
    answer:
      "Most money flows to where other money already went. That's not investing\u2014it's following. The markets that matter most are the ones capital hasn't reached yet. That's where we operate.",
  },
  {
    question: "Back what others won't",
    answer:
      "The best companies are built where consensus is wrong. Every market that looks obvious today was once dismissed as too small, too hard, or too early. We exist to find those moments before anyone else does\u2014and to build with the people crazy enough to go after them.",
  },
  {
    question: "Don't do pattern matching",
    answer:
      "The next defining company won't look like the last one. Pattern matching is how you fund copies of what already exists. We'd rather understand why something could work than check if it fits a template.",
  },
  {
    question: "Fail on something that matters",
    answer:
      "Safe bets produce safe outcomes. We're not here to build another incremental improvement. If we're going to spend years on something, it should be worth the risk of being wrong.",
  },
  {
    question: "Think in decades, not demo days",
    answer:
      "The hardest problems don't resolve in 12 weeks. We don't pressure founders into artificial timelines or premature scaling. Build it right. We'll be here.",
  },
  {
    question: "Conviction doesn't need consensus",
    answer:
      "We've never needed a room full of people to agree before we move. One person with deep understanding of a problem is worth more than a hundred who've read the same market report.",
  },
  {
    question: "Odds measure consensus, not potential",
    answer:
      "Low odds just mean most people disagree\u2014it says nothing about whether you're right. The entire history of transformative companies is a history of bets that looked irrational at the time. We'd rather be non-consensus and right than safe and irrelevant.",
  },
  {
    question: "The asymmetry is in underserved markets",
    answer:
      "A billion people, entire industries being built from scratch, problems that can't be solved with copy-paste playbooks from Silicon Valley. The founders building here aren't just starting companies\u2014they're defining categories. That's where we want to be.",
  },
  {
    question: "Build the ecosystem, not just the companies.",
    answer:
      "Infrastructure, talent, community\u2014none of it exists yet in the markets we operate in, so we build it ourselves. Every makerspace we open, every builder we train, every founder we back adds a node to a network that didn't exist before. We're not waiting for the ecosystem to mature. We are the ecosystem maturing.",
  },
  {
    question: "Small markets today, inevitable markets tomorrow",
    answer:
      "Every massive market was once too small to matter. Mobile payments in Africa, telemedicine in rural communities, digital identity for the unbanked\u2014these weren't trends when the first builders started. They were convictions.",
  },
  {
    question: "If you're building something hard, you can just reach out.",
    answer:
      "Use the form below or email hello@cr4fts.com. Skip the formalities\u2014tell us what you're building, why it matters, and why now. We read everything. If it resonates, we'll respond fast.",
  },
]

function FAQItemRow({
  question,
  answer,
}: {
  question: string
  answer: string
}) {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <button
        onClick={() => setOpen(!open)}
        className="w-full text-left flex items-start gap-2 py-1.5 cursor-pointer"
      >
        <svg
          className={`w-4 h-4 mt-0.5 flex-shrink-0 text-[#9B9B9B] transition-transform duration-200 ${open ? "rotate-90" : ""}`}
          viewBox="0 0 16 16"
          fill="currentColor"
        >
          <path d="M6 4l4 4-4 4V4z" />
        </svg>
        <span className="text-base font-semibold text-black">
          {question}
        </span>
      </button>
      {open && (
        <div className="pl-6 pb-2">
          <p className="text-base text-[#6B6B6B] leading-relaxed">
            {answer}
          </p>
        </div>
      )}
    </div>
  )
}

interface FAQProps {
  faqs: FaqItem[]
}

export default function FAQ({ faqs }: FAQProps) {
  const items = faqs.length > 0
    ? faqs.map((f) => ({ question: f.question, answer: f.answer }))
    : fallbackFaqs

  return (
    <div id="convictions" className="py-12 md:py-16">
      <div className="mb-4">
        <h2 className="text-lg font-bold text-black">Convictions</h2>
        <p className="text-sm text-[#9B9B9B]">What we believe</p>
      </div>

      <div>
        {items.map((item, index) => (
          <FAQItemRow key={index} question={item.question} answer={item.answer} />
        ))}
      </div>
    </div>
  )
}
