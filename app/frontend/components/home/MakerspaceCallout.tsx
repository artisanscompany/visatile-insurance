export default function MakerspaceCallout() {
  return (
    <div id="hackerspace" className="relative py-16 md:py-20 lg:py-28 overflow-visible">
      {/* Skewed container */}
      <div
        className="absolute inset-0 transform -skew-y-[0.5deg] shadow-2xl rounded-3xl overflow-hidden"
        style={{ backgroundColor: "#17233C" }}
      >
        {/* Subtle background images */}
        <div className="absolute inset-0 rounded-3xl opacity-10">
          <img
            src="https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=1200&h=800&fit=crop"
            alt=""
            className="absolute top-0 left-0 w-1/3 h-1/2 object-cover transform rotate-12 blur-sm"
          />
          <img
            src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1200&h=800&fit=crop"
            alt=""
            className="absolute bottom-0 right-0 w-1/3 h-1/2 object-cover transform -rotate-6 blur-sm"
          />
          <img
            src="https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=1200&h=800&fit=crop"
            alt=""
            className="absolute top-1/3 right-1/4 w-1/4 h-1/3 object-cover transform rotate-3 blur-sm"
          />
        </div>
      </div>

      <div className="relative mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-12 items-center">
          {/* Content Column */}
          <div className="text-center md:text-left">
            <h2 className="text-2xl md:text-3xl lg:text-4xl font-black mb-4 leading-tight text-white">
              One more thing... Join us at Makerspace
            </h2>
            <div className="mb-8">
              <p
                className="text-base md:text-lg lg:text-xl leading-relaxed text-white"
                style={{ opacity: 0.9 }}
              >
                Our physical workspace in Nairobi where builders, makers, and
                founders come together to create. Whether you&apos;re
                prototyping hardware, shipping software, or just building the
                next thing&mdash; Makerspace is where it happens.
              </p>
            </div>
            <a
              href="https://www.google.com/maps/dir//Right+Wing,+9+Kiambere+Rd,+Nairobi,+Kenya/@51.5044672,-0.0821554,14z/data=!4m8!4m7!1m0!1m5!1m1!1s0x182f11f6874cb19d:0xdf05f61114183e!2m2!1d36.8222255!2d-1.3020511?entry=ttu&g_ep=EgoyMDI2MDEwNy4wIKXMDSoASAFQAw%3D%3D"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-3 px-8 py-4 md:px-10 md:py-5 bg-white text-base md:text-lg font-bold rounded-xl hover:shadow-xl transition-all group"
              style={{ color: "#17233C" }}
            >
              Visit Us
              <svg
                className="w-5 h-5 group-hover:translate-x-1 transition-transform"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2.5"
                  d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                />
              </svg>
            </a>
          </div>

          {/* Image Column */}
          <div className="hidden md:flex justify-center items-center">
            <div className="relative w-80 h-80">
              <img
                src="/images/hackerspace.jpg"
                alt="Makerspace Community"
                className="w-full h-full object-cover rounded-2xl shadow-2xl border-4 border-white/10"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
