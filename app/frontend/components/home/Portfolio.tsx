import { ventures } from "@/lib/ventures"

function VentureCard({ ventureKey }: { ventureKey: string }) {
  const venture = ventures[ventureKey]

  return (
    <div className="block w-full pb-[100%] relative group overflow-hidden rounded-3xl shadow-xl transition-all duration-500 venture-card border-4 border-white cursor-default">
      <div className="absolute inset-0">
        <img
          src={venture.image}
          alt={venture.subtitle}
          className="w-full h-full object-cover grayscale"
        />
      </div>
      <div className="absolute inset-0 bg-gradient-to-br from-black/60 to-black/30" />
      <div className="absolute inset-0 flex flex-col justify-end items-start p-4 md:p-5 lg:p-6">
        <h3 className="text-base md:text-lg font-black text-white leading-tight text-left">
          {venture.subtitle}
        </h3>
      </div>
    </div>
  )
}

function FeaturedCard({ ventureKey }: { ventureKey: string }) {
  const venture = ventures[ventureKey]

  return (
    <div className="block w-full pb-[100%] relative group overflow-hidden rounded-3xl shadow-xl transition-all duration-500 venture-card border-4 border-white cursor-default">
      <div className="absolute inset-0">
        <img
          src={venture.image}
          alt={venture.subtitle}
          className="w-full h-full object-cover grayscale"
        />
      </div>
      <div className="absolute inset-0 bg-gradient-to-br from-black/60 to-black/30" />
      <div className="absolute inset-0 flex flex-col justify-end items-start p-6 md:p-8">
        <h3 className="text-2xl md:text-3xl font-black text-white leading-tight text-left">
          {venture.subtitle}
        </h3>
      </div>
    </div>
  )
}

function EmptySlot() {
  return (
    <div
      className="block w-full pb-[100%] relative group overflow-hidden rounded-3xl shadow-lg transition-all duration-500 venture-card border-4 border-dashed"
      style={{
        borderColor: "rgba(23, 35, 60, 0.2)",
        background: "linear-gradient(135deg, rgba(23, 35, 60, 0.03) 0%, rgba(23, 35, 60, 0.06) 100%)",
      }}
    >
      <div className="absolute inset-0 flex flex-col items-center justify-center p-4 md:p-5">
        <div
          className="w-12 h-12 md:w-16 md:h-16 rounded-full mb-3 flex items-center justify-center transition-transform duration-500 group-hover:scale-110"
          style={{ backgroundColor: "rgba(23, 35, 60, 0.1)" }}
        >
          <svg
            className="w-6 h-6 md:w-8 md:h-8"
            style={{ color: "rgba(23, 35, 60, 0.3)" }}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
          </svg>
        </div>
        <p className="text-xs md:text-sm font-bold text-center" style={{ color: "rgba(23, 35, 60, 0.4)" }}>
          Coming Soon
        </p>
      </div>
    </div>
  )
}

export default function Portfolio() {
  return (
    <div id="ventures" className="relative py-16 md:py-24 scroll-mt-20">
      <div className="mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Heading */}
        <div className="text-center mb-12 md:mb-16">
          <h2
            className="text-2xl md:text-3xl lg:text-4xl font-black leading-snug mb-2 md:mb-3"
            style={{ color: "#17233C", letterSpacing: "-0.02em", wordSpacing: "-0.05em" }}
          >
            Bets we are making.
          </h2>
          <p
            className="text-xl md:text-2xl lg:text-3xl leading-relaxed font-light"
            style={{ color: "#17233C", opacity: 0.8 }}
          >
            Our stakes on hard problems and long odds.
          </p>
        </div>

        {/* Top Section: 1 Featured + 4 Cards */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6 mb-4 md:mb-6">
          {/* Featured Card - Large 2x2 */}
          <div className="col-span-2 md:col-span-2 md:row-span-2">
            <FeaturedCard ventureKey="hisdoctor" />
          </div>

          <div className="col-span-1">
            <VentureCard ventureKey="visatile" />
          </div>
          <div className="col-span-1">
            <VentureCard ventureKey="build54" />
          </div>
          <div className="col-span-1">
            <VentureCard ventureKey="notarials" />
          </div>
          <div className="col-span-1">
            <VentureCard ventureKey="corppy" />
          </div>
        </div>

        {/* Bottom Section: 6 Cards Grid */}
        <div className="grid grid-cols-2 md:grid-cols-6 gap-4 md:gap-6">
          <div className="col-span-1">
            <VentureCard ventureKey="repoless" />
          </div>
          <div className="col-span-1">
            <VentureCard ventureKey="recordness" />
          </div>
          <div className="col-span-1">
            <VentureCard ventureKey="clauseless" />
          </div>
          <div className="col-span-1">
            <VentureCard ventureKey="hospiceble" />
          </div>
          <div className="col-span-1">
            <EmptySlot />
          </div>
          <div className="col-span-1">
            <EmptySlot />
          </div>
        </div>
      </div>
    </div>
  )
}
