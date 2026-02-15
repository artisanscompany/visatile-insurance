import { useState } from "react"

const faqItems = [
  {
    question: "What makes CR4FTS different from other studios?",
    answer:
      "We focus exclusively on underserved markets and hard problems that others overlook. We're not chasing hot trends or proven markets\u2014we're building companies where the odds say we shouldn't.",
    rotate: "rotate-1",
  },
  {
    question: "Are you taking on new builders?",
    answer:
      "Yes. If you're building something hard and tired of hearing no, reach out. We work with founders who care about solving real problems in overlooked markets.",
    rotate: "-rotate-1",
  },
  {
    question: "Do you accept external companies?",
    answer:
      "Yes, we incubate companies from the idea stage. If you're tackling underserved markets and hard problems, we provide hands-on support to help you build and scale.",
    rotate: "rotate-1",
  },
  {
    question: "What do you provide to companies you work with?",
    answer:
      "We provide capital, hands-on operational support, technical expertise, and access to our network. We work alongside founders to build, scale, and navigate the challenges of underserved markets.",
    rotate: "-rotate-1",
  },
  {
    question: "Do you run cohorts or accept applications on a rolling basis?",
    answer:
      "We accept applications on a rolling basis. There are no cohorts or fixed deadlines\u2014if you're building something that fits our thesis, reach out anytime.",
    rotate: "rotate-1",
  },
  {
    question: 'What does "stealth mode" mean for your ventures?',
    answer:
      "We're actively building these companies but keeping details private until the right moment. They're in development, not dormant.",
    rotate: "-rotate-1",
  },
  {
    question: "What is your social enterprise program?",
    answer:
      "We run a social enterprise program through Build54, supporting non-profits that tackle critical societal challenges. If you're building solutions that create meaningful impact in underserved communities, we want to hear from you.",
    rotate: "rotate-1",
  },
  {
    question: "How can I get in touch?",
    answer: "",
    answerHtml: true,
    rotate: "-rotate-1",
  },
]

function FAQItem({
  question,
  answer,
  answerHtml,
  rotate,
}: {
  question: string
  answer: string
  answerHtml?: boolean
  rotate: string
}) {
  const [open, setOpen] = useState(false)

  return (
    <div
      className={`p-6 md:p-8 border rounded-2xl transform ${rotate} relative`}
      style={{ backgroundColor: "#FFFFFF", borderColor: "#E5E7EB" }}
    >
      <button
        onClick={() => setOpen(!open)}
        className="w-full text-left flex items-center justify-between hover:opacity-80 transition-opacity cursor-pointer"
      >
        <h3
          className="text-lg md:text-xl font-black pr-8"
          style={{ color: "#17233C", letterSpacing: "-0.02em" }}
        >
          {question}
        </h3>
        <svg
          className={`w-6 h-6 flex-shrink-0 transition-transform duration-300 ${open ? "rotate-180" : ""}`}
          style={{ color: "#17233C" }}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      {open && (
        <div className="pt-4">
          {answerHtml ? (
            <p
              className="text-lg md:text-xl font-light leading-relaxed"
              style={{ color: "#17233C", opacity: 0.8 }}
            >
              Reach out through our contact form or email us at{" "}
              <a href="mailto:hello@cr4fts.com" className="font-bold hover:underline" style={{ color: "#60A5FA" }}>
                hello@cr4fts.com
              </a>
              . We read everything and respond to what resonates.
            </p>
          ) : (
            <p
              className="text-lg md:text-xl font-light leading-relaxed"
              style={{ color: "#17233C", opacity: 0.8 }}
            >
              {answer}
            </p>
          )}
        </div>
      )}
    </div>
  )
}

export default function FAQ() {
  return (
    <div className="relative py-16 md:py-24">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Heading */}
        <div className="text-center mb-12 md:mb-16">
          <h2
            className="text-2xl md:text-3xl lg:text-4xl font-black leading-snug mb-2 md:mb-3"
            style={{ color: "#17233C", letterSpacing: "-0.02em", wordSpacing: "-0.05em" }}
          >
            Quick answers.
          </h2>
          <p
            className="text-xl md:text-2xl lg:text-3xl leading-relaxed font-light"
            style={{ color: "#17233C", opacity: 0.8 }}
          >
            To the questions we hear most.
          </p>
        </div>

        {/* FAQ Accordion Items */}
        <div className="space-y-6">
          {faqItems.map((item, index) => (
            <FAQItem key={index} {...item} />
          ))}
        </div>
      </div>
    </div>
  )
}
