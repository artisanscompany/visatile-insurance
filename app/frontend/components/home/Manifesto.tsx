export default function Manifesto() {
  return (
    <div className="relative pt-2 md:pt-4 pb-16 md:pb-24">
      {/* Paper Container */}
      <div
        className="p-8 md:p-12 lg:p-16 border transform -rotate-1 relative"
        style={{ backgroundColor: "#FFFFFF", borderColor: "#E5E7EB" }}
      >
        {/* Vertical Crease Shadow */}
        <div
          className="hidden lg:block absolute top-0 bottom-0 left-1/2 w-8 transform -translate-x-1/2 pointer-events-none"
          style={{
            background:
              "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.03) 45%, rgba(0,0,0,0.05) 50%, rgba(0,0,0,0.03) 55%, transparent 100%)",
          }}
        />

        {/* Two Column Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16">
          {/* Left Column */}
          <div>
            <div className="mb-6 md:mb-8">
              <p className="text-xl md:text-2xl font-light leading-relaxed" style={{ color: "#17233C" }}>
                There are odds no one is taking. The markets that are too risky,
                founders that are too unproven, sectors that are too regulated,
                niches that are not hot enough, monopolies that are too strong to
                beat, regions with capital too scarce.
              </p>
            </div>

            <div className="mb-6 md:mb-8">
              <p className="text-xl md:text-2xl font-light leading-relaxed" style={{ color: "#17233C" }}>
                So, while billions flow to the same cities, the same founder
                archetype, the same ideas, the same thesis and opportunites,
                many problems sit unsolved and opportunities untapped beacuse
                the odds are too low.
              </p>
            </div>

            <div>
              <p className="text-xl md:text-2xl font-light leading-relaxed" style={{ color: "#17233C" }}>
                We are the people taking the 1% odds no one else is.
              </p>
            </div>
          </div>

          {/* Right Column */}
          <div>
            <div className="mb-6 md:mb-8">
              <p className="text-xl md:text-2xl font-light leading-relaxed" style={{ color: "#17233C" }}>
                We don&apos;t confuse odds with outcomes, because odds are a
                measure of consensus, not potential. The defining outcomes,
                markets, companies, and solutions, almost always started as
                crazy bets some lunatics made.
              </p>
            </div>

            <div className="mb-6 md:mb-8">
              <p className="text-xl md:text-2xl font-light leading-relaxed" style={{ color: "#17233C" }}>
                If you are that type of lunatic, we&apos;d love to hear from
                you. If you&apos;re building something impactful and hard that
                no one will touch, you&apos;ve found your people. If you invest
                in what others won&apos;t, let&apos;s talk. If you want to work
                on impossible things that actually matter, we&apos;re here.
              </p>
            </div>

            {/* Signature */}
            <div className="mt-8">
              <p className="text-xl md:text-2xl font-light mb-1" style={{ color: "#17233C" }}>
                Usman
              </p>
              <a
                href="mailto:usman@cr4fts.com"
                className="text-lg md:text-xl font-light hover:underline"
                style={{ color: "#17233C", opacity: 0.7 }}
              >
                usman@cr4fts.com
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
