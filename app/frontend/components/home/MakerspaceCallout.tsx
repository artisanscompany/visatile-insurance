export default function MakerspaceCallout() {
  return (
    <div id="makerspace" className="py-12 md:py-16">
      <div>
        <h2 className="text-lg font-bold text-black">Makerspace</h2>
        <p className="text-sm text-[#9B9B9B] mb-3">Our workshop in Nairobi</p>
        <p className="text-base text-[#6B6B6B] leading-relaxed mb-3 max-w-2xl">
          Our physical workspace in Nairobi where builders, makers, and
          founders come together to create. Whether you&apos;re
          prototyping hardware, shipping software, or just building the
          next thing&mdash;Makerspace is where it happens.
        </p>
        <a
          href="https://www.google.com/maps/dir//Right+Wing,+9+Kiambere+Rd,+Nairobi,+Kenya/@51.5044672,-0.0821554,14z/data=!4m8!4m7!1m0!1m5!1m1!1s0x182f11f6874cb19d:0xdf05f61114183e!2m2!1d36.8222255!2d-1.3020511?entry=ttu&g_ep=EgoyMDI2MDEwNy4wIKXMDSoASAFQAw%3D%3D"
          target="_blank"
          rel="noopener noreferrer"
          className="text-base text-[#6B6B6B] hover:underline hover:text-black inline-flex items-center gap-1 transition-colors"
        >
          Get directions
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
          </svg>
        </a>
      </div>
    </div>
  )
}
