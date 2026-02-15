export default function Hero() {
  return (
    <div className="relative pt-16 md:pt-24 pb-2 md:pb-4 overflow-hidden">
      {/* Desktop: 3 Column Image Grid */}
      <div className="hidden md:block relative mx-auto px-4 mb-0">
        <div className="grid grid-cols-3 gap-4">
          {/* Column 1 */}
          <div className="space-y-4">
            <div className="transform rotate-2 hover:rotate-0 transition-transform">
              <img
                src="/images/hero-image.jpg"
                alt="CR4FTS Vision"
                className="w-full aspect-[4/3] object-cover rounded-lg shadow-lg border-2 border-white"
              />
            </div>
            <div className="transform -rotate-3 hover:-rotate-1 transition-transform -mt-8 ml-4">
              <img
                src="/images/hero-image-2.jpg"
                alt="CR4FTS Innovation"
                className="w-full aspect-[4/3] object-cover rounded-lg shadow-lg border-2 border-white"
              />
            </div>
          </div>

          {/* Column 2 */}
          <div className="space-y-4 mt-6">
            <div className="transform -rotate-2 hover:rotate-0 transition-transform">
              <img
                src="/images/hero-image-3.jpg"
                alt="CR4FTS Building"
                className="w-full aspect-[4/3] object-cover rounded-lg shadow-lg border-2 border-white"
              />
            </div>
            <div className="transform rotate-3 hover:rotate-1 transition-transform -mt-6 -mr-4">
              <img
                src="/images/hero-image-4.jpg"
                alt="CR4FTS Development"
                className="w-full aspect-[4/3] object-cover rounded-lg shadow-lg border-2 border-white"
              />
            </div>
          </div>

          {/* Column 3 */}
          <div className="space-y-4 mt-2">
            <div className="transform rotate-3 hover:rotate-1 transition-transform">
              <img
                src="/images/hero-image-5.jpg"
                alt="CR4FTS Innovation"
                className="w-full aspect-[4/3] object-cover rounded-lg shadow-lg border-2 border-white"
              />
            </div>
            <div className="transform -rotate-2 hover:rotate-0 transition-transform -mt-8 -ml-4">
              <img
                src="/images/hero-image-6.jpg"
                alt="CR4FTS Strategy"
                className="w-full aspect-[4/3] object-cover rounded-lg shadow-lg border-2 border-white"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Mobile: 2x2 Grid */}
      <div className="block md:hidden mx-auto px-4 mb-0">
        <div className="grid grid-cols-2 gap-3">
          <div className="transform rotate-2">
            <img
              src="/images/hero-image.jpg"
              alt="CR4FTS Vision"
              className="w-full aspect-square object-cover rounded-lg shadow-lg border-2 border-white"
            />
          </div>
          <div className="transform -rotate-2 mt-4">
            <img
              src="/images/hero-image-2.jpg"
              alt="CR4FTS Innovation"
              className="w-full aspect-square object-cover rounded-lg shadow-lg border-2 border-white"
            />
          </div>
          <div className="transform -rotate-1 -mt-4">
            <img
              src="/images/hero-image-3.jpg"
              alt="CR4FTS Building"
              className="w-full aspect-square object-cover rounded-lg shadow-lg border-2 border-white"
            />
          </div>
          <div className="transform rotate-2">
            <img
              src="/images/hero-image-4.jpg"
              alt="CR4FTS Development"
              className="w-full aspect-square object-cover rounded-lg shadow-lg border-2 border-white"
            />
          </div>
        </div>
      </div>

      {/* Headline and Description */}
      <div className="text-center pt-8 md:pt-12">
        <h2
          className="text-2xl md:text-3xl lg:text-4xl font-black leading-snug mb-2 md:mb-3 px-4"
          style={{ color: "#17233C", letterSpacing: "-0.02em", wordSpacing: "-0.05em" }}
        >
          We take the 1% odds.
        </h2>
        <div className="mx-auto px-4">
          <p
            className="text-xl md:text-2xl lg:text-3xl leading-relaxed font-light"
            style={{ color: "#17233C", opacity: 0.8 }}
          >
            Build what the probabilities say you can&apos;t.
          </p>
        </div>
      </div>
    </div>
  )
}
