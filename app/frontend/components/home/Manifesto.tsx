export default function Manifesto() {
  return (
    <div className="py-12 md:py-16">
      <div className="mb-4">
        <h2 className="text-lg font-bold text-black">Our thesis</h2>
        <p className="text-sm text-[#9B9B9B]">Why we exist</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-12">
        <div className="space-y-4">
          <p className="text-base text-[#6B6B6B] leading-relaxed">
            There are odds no one is taking. The markets that are too risky,
            founders that are too unproven, sectors that are too regulated,
            niches that are not hot enough, monopolies that are too strong to
            beat, regions with capital too scarce.
          </p>
          <p className="text-base text-[#6B6B6B] leading-relaxed">
            So, while billions flow to the same cities, the same founder
            archetype, the same ideas, the same thesis and opportunites,
            many problems sit unsolved and opportunities untapped beacuse
            the odds are too low.
          </p>
          <p className="text-base text-[#6B6B6B] leading-relaxed">
            We are the people taking the 1% odds no one else is.
          </p>
        </div>

        <div className="space-y-4">
          <p className="text-base text-[#6B6B6B] leading-relaxed">
            We don&apos;t confuse odds with outcomes, because odds are a
            measure of consensus, not potential. The defining outcomes,
            markets, companies, and solutions, almost always started as
            crazy bets some lunatics made.
          </p>
          <p className="text-base text-[#6B6B6B] leading-relaxed">
            If you are that type of lunatic, we&apos;d love to hear from
            you. If you&apos;re building something impactful and hard that
            no one will touch, you&apos;ve found your people. If you invest
            in what others won&apos;t, let&apos;s talk. If you want to work
            on impossible things that actually matter, we&apos;re here.
          </p>
        </div>
      </div>
    </div>
  )
}
