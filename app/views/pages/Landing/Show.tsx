import { Head } from '@inertiajs/react'
import {
  Shield,
  Plane,
  HeartPulse,
  Luggage,
  Clock,
  Star,
  ArrowRight,
  ArrowUpRight,
  Menu,
  X,
  Umbrella,
  Mountain,
  Waves,
  Bike,
  Tent,
  Sailboat,
  CheckCircle2,
} from 'lucide-react'
import { useState } from 'react'
import { QuickQuote } from './components/QuickQuote'

const COVERAGE_ITEMS = [
  {
    icon: HeartPulse,
    title: 'Medical Emergencies',
    description: 'Hospital bills, specialist visits, surgery, and emergency evacuation — covered anywhere on the planet. No caps on emergencies.',
    image: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1000&q=90',
    tag: 'Most claimed',
    stat: 'Up to $500k',
    statLabel: 'medical coverage',
    color: 'bg-violet-600',
  },
  {
    icon: Plane,
    title: 'Trip Cancellation',
    description: 'Life happens. Recoup 100% of non-refundable trip costs when illness, weather, or anything else forces you to cancel.',
    image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1000&q=90',
    tag: null,
    stat: '100%',
    statLabel: 'reimbursement',
    color: 'bg-yellow-400',
  },
  {
    icon: Luggage,
    title: 'Lost Baggage',
    description: 'Airline lost your bags? You\'re covered for the contents and essentials while you wait — so you\'re never stranded.',
    image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=1000&q=90',
    tag: null,
    stat: '$3,000',
    statLabel: 'baggage limit',
    color: 'bg-black',
  },
  {
    icon: Clock,
    title: 'Travel Delays',
    description: 'Stuck at the airport? Meals, hotels, and transfers covered from hour one when flights are delayed or cancelled.',
    image: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1000&q=90',
    tag: null,
    stat: 'From hour 1',
    statLabel: 'delay cover kicks in',
    color: 'bg-violet-600',
  },
  {
    icon: Umbrella,
    title: 'Personal Liability',
    description: 'If you accidentally injure someone or damage property abroad, we\'ve got you covered against legal costs and compensation.',
    image: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=1000&q=90',
    tag: null,
    stat: '$2M',
    statLabel: 'liability cover',
    color: 'bg-yellow-400',
  },
  {
    icon: Shield,
    title: '24/7 Assistance',
    description: 'Real humans answer the phone, day or night. Wherever you are, whatever the crisis — we pick up.',
    image: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=1000&q=90',
    tag: 'Always on',
    stat: '< 2 min',
    statLabel: 'avg. response time',
    color: 'bg-black',
  },
]

const DESTINATIONS = [
  {
    name: 'Europe',
    countries: '40+ countries',
    image: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=900&q=85',
    highlight: 'Schengen & beyond',
  },
  {
    name: 'Asia Pacific',
    countries: '25+ countries',
    image: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=900&q=85',
    highlight: 'From Bali to Tokyo',
  },
  {
    name: 'The Americas',
    countries: '35+ countries',
    image: 'https://images.unsplash.com/photo-1518391846015-55a9cc003b25?w=900&q=85',
    highlight: 'North to South',
  },
  {
    name: 'Africa & Middle East',
    countries: '30+ countries',
    image: 'https://images.unsplash.com/photo-1489392191049-fc10c97e64b6?w=900&q=85',
    highlight: 'Wild & wonderful',
  },
]

const ACTIVITIES = [
  { name: 'Beach & Water Sports', icon: Waves, image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=700&q=85' },
  { name: 'Hiking & Trekking', icon: Mountain, image: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=700&q=85' },
  { name: 'Winter Sports', icon: Mountain, image: 'https://images.unsplash.com/photo-1551524559-8af4e6624178?w=700&q=85' },
  { name: 'Cycling Tours', icon: Bike, image: 'https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=700&q=85' },
  { name: 'Sailing & Boating', icon: Sailboat, image: 'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=700&q=85' },
  { name: 'Camping & Outdoor', icon: Tent, image: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=700&q=85' },
]

const TESTIMONIALS = [
  {
    name: 'Sarah M.',
    location: 'Bangkok, Thailand',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
    text: 'They covered $12,000 of hospital bills without a single argument. I\'ve never felt so taken care of abroad.',
    rating: 5,
  },
  {
    name: 'James & Emma',
    location: 'Maldives',
    avatar: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=100&q=80',
    text: 'Our honeymoon got disrupted by a storm. TravelShield sorted us out within 24 hours. Absolute lifesavers.',
    rating: 5,
  },
  {
    name: 'Diego R.',
    location: 'Frequent business traveler',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
    text: 'I fly 200+ days a year. This is the only insurance I trust. Claims are fast, team is brilliant.',
    rating: 5,
  },
]

export default function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  return (
    <>
      <Head title="TravelShield — Travel Insurance Made Simple" />

      <div className="min-h-screen bg-[#fafaf8] font-sans">

        {/* ── HEADER ─────────────────────────────────────── */}
        <header className="fixed top-0 left-0 right-0 z-50 bg-[#fafaf8]/90 backdrop-blur-md border-b border-black/8">
          <div className="max-w-7xl mx-auto px-5 sm:px-8">
            <div className="flex items-center justify-between h-[68px]">
              <a href="/" className="flex items-center gap-2.5 group">
                <div className="w-9 h-9 bg-black rounded-xl flex items-center justify-center group-hover:bg-violet-600 transition-colors">
                  <Shield className="w-5 h-5 text-white" />
                </div>
                <span className="text-[1.1rem] font-bold tracking-tight text-black">TravelShield</span>
              </a>

              <nav className="hidden md:flex items-center gap-7">
                {['Coverage', 'Destinations', 'Activities'].map(item => (
                  <a
                    key={item}
                    href={`#${item.toLowerCase()}`}
                    className="text-sm font-medium text-gray-500 hover:text-black transition-colors"
                  >
                    {item}
                  </a>
                ))}
                <div className="w-px h-4 bg-gray-300" />
                <a href="/session/new" className="text-sm font-medium text-gray-500 hover:text-black transition-colors">
                  Login
                </a>
                <a
                  href="/insurance/quote"
                  className="inline-flex items-center gap-1.5 bg-black text-white text-sm font-semibold px-4 py-2 rounded-xl hover:bg-violet-600 transition-colors"
                >
                  Get a Quote <ArrowUpRight className="w-3.5 h-3.5" />
                </a>
              </nav>

              <button className="md:hidden p-2 -mr-2" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
                {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
              </button>
            </div>
          </div>

          {mobileMenuOpen && (
            <div className="md:hidden bg-[#fafaf8] border-t border-black/8 px-5 py-5 space-y-1">
              {['Coverage', 'Destinations', 'Activities'].map(item => (
                <a key={item} href={`#${item.toLowerCase()}`} className="block py-2.5 text-sm font-medium text-gray-700">
                  {item}
                </a>
              ))}
              <a href="/session/new" className="block py-2.5 text-sm font-medium text-gray-700">Login</a>
              <div className="pt-2">
                <a href="/insurance/quote" className="block text-center bg-black text-white text-sm font-semibold px-4 py-3 rounded-xl">
                  Get a Quote
                </a>
              </div>
            </div>
          )}
        </header>

        {/* ── HERO ───────────────────────────────────────── */}
        <section className="relative min-h-screen flex flex-col pt-[68px] overflow-hidden bg-black">
          {/* Full bleed image */}
          <div className="absolute inset-0">
            <img
              src="https://images.unsplash.com/photo-1488085061387-422e29b40080?w=1920&q=90"
              alt="Aerial view of airplane wing at sunset"
              className="w-full h-full object-cover opacity-50"
            />
          </div>

          {/* Content */}
          <div className="relative z-10 flex-1 flex flex-col justify-between max-w-7xl mx-auto w-full px-5 sm:px-8 py-16">
            {/* Top badge */}
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-1.5 bg-white/10 border border-white/20 rounded-full px-3.5 py-1.5">
                {[1,2,3,4,5].map(i => <Star key={i} className="w-3 h-3 text-yellow-400 fill-yellow-400" />)}
                <span className="text-white text-xs font-medium ml-1">50,000+ travelers trust us</span>
              </div>
            </div>

            {/* Big headline + form */}
            <div className="grid lg:grid-cols-[1fr_420px] gap-12 items-end">
              <div className="space-y-8">
                <h1 className="text-[clamp(3.2rem,8vw,7rem)] font-black leading-[0.92] tracking-tight text-white">
                  Adventure<br/>
                  <span className="text-yellow-400">awaits.</span><br/>
                  We've got<br/>
                  you.
                </h1>

                <p className="text-lg text-white/70 max-w-md leading-relaxed">
                  Travel insurance that's genuinely simple — covered in minutes, claim in clicks.
                </p>

                <div className="flex flex-wrap gap-x-6 gap-y-2">
                  {['No hidden fees', 'Instant coverage', 'Global 24/7 support'].map(f => (
                    <div key={f} className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-yellow-400 flex-shrink-0" />
                      <span className="text-white/80 text-sm">{f}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="w-full">
                <QuickQuote />
              </div>
            </div>
          </div>

          {/* Bottom ticker */}
          <div className="relative z-10 border-t border-white/10 bg-white/5 backdrop-blur-sm">
            <div className="max-w-7xl mx-auto px-5 sm:px-8 py-3 flex items-center gap-8 overflow-hidden">
              {['Medical Coverage', 'Trip Cancellation', 'Lost Baggage', 'Flight Delays', 'Personal Liability', '24/7 Assistance'].map((item, i) => (
                <span key={i} className="text-white/50 text-xs font-medium tracking-widest uppercase whitespace-nowrap flex items-center gap-4">
                  {item}
                  {i < 5 && <span className="text-yellow-400">·</span>}
                </span>
              ))}
            </div>
          </div>
        </section>

        {/* ── WHAT'S COVERED ─────────────────────────────── */}
        <section id="coverage" className="bg-[#fafaf8]">
          {/* Section header — full width */}
          <div className="max-w-7xl mx-auto px-5 sm:px-8 pt-24 pb-16">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-6">
              <div>
                <p className="text-xs font-bold tracking-[0.2em] uppercase text-violet-600 mb-3">Protection</p>
                <h2 className="text-[clamp(2.5rem,6vw,4.5rem)] font-black leading-[0.9] tracking-tight text-black">
                  What's<br/>covered
                </h2>
              </div>
              <p className="text-gray-500 max-w-sm text-base leading-relaxed sm:text-right">
                Every plan covers you from minor headaches to full-blown emergencies.
              </p>
            </div>
          </div>

          {/* Alternating editorial rows */}
          <div className="divide-y divide-gray-200 border-t border-gray-200">
            {COVERAGE_ITEMS.map((item, i) => {
              const isEven = i % 2 === 0
              return (
                <div key={i} className="group overflow-hidden">
                  <div className={`grid lg:grid-cols-2 ${isEven ? '' : 'lg:grid-flow-col-dense'}`}>
                    {/* Image side */}
                    <div className={`relative overflow-hidden h-64 lg:h-80 ${isEven ? '' : 'lg:col-start-2'}`}>
                      <img
                        src={item.image}
                        alt={item.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                      />
                      {/* Colour wash overlay matching item color */}
                      <div className={`absolute inset-0 ${item.color} opacity-20 mix-blend-multiply`} />
                      {/* Tag pill */}
                      {item.tag && (
                        <div className="absolute top-4 left-4 bg-yellow-400 text-black text-[0.65rem] font-black uppercase tracking-[0.15em] px-3 py-1.5 rounded-full">
                          {item.tag}
                        </div>
                      )}
                    </div>

                    {/* Text side */}
                    <div className={`flex flex-col justify-center px-8 py-12 lg:px-16 bg-white ${isEven ? '' : 'lg:col-start-1 lg:row-start-1'}`}>
                      {/* Number + icon row */}
                      <div className="flex items-center gap-4 mb-6">
                        <span className="text-[0.65rem] font-black text-gray-300 tracking-[0.2em] uppercase">
                          {String(i + 1).padStart(2, '0')}
                        </span>
                        <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${item.color} ${item.color === 'bg-yellow-400' ? 'text-black' : 'text-white'}`}>
                          <item.icon className="w-4.5 h-4.5" />
                        </div>
                        <div className="flex-1 h-px bg-gray-100" />
                      </div>

                      <h3 className="text-2xl lg:text-3xl font-black text-black mb-3 leading-tight tracking-tight">
                        {item.title}
                      </h3>
                      <p className="text-gray-500 text-base leading-relaxed mb-8 max-w-sm">
                        {item.description}
                      </p>

                      {/* Big stat */}
                      <div className="flex items-baseline gap-3 pt-6 border-t border-gray-100">
                        <span className={`text-3xl font-black tracking-tight ${item.color === 'bg-yellow-400' ? 'text-yellow-500' : item.color === 'bg-violet-600' ? 'text-violet-600' : 'text-black'}`}>
                          {item.stat}
                        </span>
                        <span className="text-sm text-gray-400 uppercase tracking-wider font-medium">{item.statLabel}</span>
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </section>

        {/* ── DESTINATIONS ───────────────────────────────── */}
        <section id="destinations" className="py-24 bg-black text-white">
          <div className="max-w-7xl mx-auto px-5 sm:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-6 mb-16">
              <div>
                <p className="text-xs font-bold tracking-[0.2em] uppercase text-yellow-400 mb-3">Worldwide</p>
                <h2 className="text-[clamp(2.2rem,5vw,3.8rem)] font-black leading-tight tracking-tight">
                  Destinations<br/>covered
                </h2>
              </div>
              <p className="text-white/50 max-w-sm text-base leading-relaxed">
                130+ countries. Every continent. One policy.
              </p>
            </div>

            {/* Bold grid — two large + two stacked */}
            <div className="grid grid-cols-1 lg:grid-cols-[1fr_1fr_320px] gap-4">
              {/* First large card */}
              <div className="group relative rounded-2xl overflow-hidden h-[460px] lg:h-auto cursor-pointer">
                <img
                  src={DESTINATIONS[0].image}
                  alt={DESTINATIONS[0].name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/50 transition-colors duration-300" />
                <div className="absolute bottom-6 left-6 right-6">
                  <p className="text-yellow-400 text-xs font-bold uppercase tracking-widest mb-1">{DESTINATIONS[0].highlight}</p>
                  <h3 className="text-3xl font-black text-white">{DESTINATIONS[0].name}</h3>
                  <p className="text-white/60 text-sm mt-1">{DESTINATIONS[0].countries}</p>
                </div>
              </div>

              {/* Second large card */}
              <div className="group relative rounded-2xl overflow-hidden h-[460px] lg:h-auto cursor-pointer">
                <img
                  src={DESTINATIONS[1].image}
                  alt={DESTINATIONS[1].name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/50 transition-colors duration-300" />
                <div className="absolute bottom-6 left-6 right-6">
                  <p className="text-yellow-400 text-xs font-bold uppercase tracking-widest mb-1">{DESTINATIONS[1].highlight}</p>
                  <h3 className="text-3xl font-black text-white">{DESTINATIONS[1].name}</h3>
                  <p className="text-white/60 text-sm mt-1">{DESTINATIONS[1].countries}</p>
                </div>
              </div>

              {/* Two stacked smaller cards */}
              <div className="flex flex-col gap-4">
                {DESTINATIONS.slice(2).map((d, i) => (
                  <div key={i} className="group relative rounded-2xl overflow-hidden h-52 cursor-pointer flex-1">
                    <img
                      src={d.image}
                      alt={d.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                    />
                    <div className="absolute inset-0 bg-black/45 group-hover:bg-black/55 transition-colors duration-300" />
                    <div className="absolute bottom-4 left-4 right-4">
                      <p className="text-yellow-400 text-[0.65rem] font-bold uppercase tracking-widest mb-0.5">{d.highlight}</p>
                      <h3 className="text-lg font-black text-white">{d.name}</h3>
                      <p className="text-white/60 text-xs mt-0.5">{d.countries}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* ── ACTIVITIES ─────────────────────────────────── */}
        <section id="activities" className="py-24 bg-[#fafaf8]">
          <div className="max-w-7xl mx-auto px-5 sm:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-6 mb-16">
              <div>
                <p className="text-xs font-bold tracking-[0.2em] uppercase text-violet-600 mb-3">Adventure</p>
                <h2 className="text-[clamp(2.2rem,5vw,3.8rem)] font-black leading-tight tracking-tight text-black">
                  Activities<br/>covered
                </h2>
              </div>
              <p className="text-gray-500 max-w-sm text-base leading-relaxed">
                Thrill-seeker or beach lover — your activities are protected.
              </p>
            </div>

            {/* Horizontal scroll row on mobile, grid on desktop */}
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
              {ACTIVITIES.map((activity, i) => (
                <div
                  key={i}
                  className={`group relative rounded-2xl overflow-hidden cursor-pointer ${i === 0 ? 'col-span-2 lg:col-span-1' : ''}`}
                  style={{ height: i === 0 ? '340px' : '220px' }}
                >
                  <img
                    src={activity.image}
                    alt={activity.name}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                  />
                  {/* Dark overlay — stronger at bottom */}
                  <div className="absolute inset-0 bg-black/30 group-hover:bg-black/45 transition-colors duration-300" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent" />

                  {/* Icon chip top-left */}
                  <div className="absolute top-4 left-4 w-10 h-10 bg-white/15 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/20 group-hover:bg-white/25 transition-colors">
                    <activity.icon className="w-5 h-5 text-white" />
                  </div>

                  {/* Label bottom */}
                  <div className="absolute bottom-4 left-4 right-4">
                    <h3 className="text-base font-bold text-white leading-tight">{activity.name}</h3>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── TESTIMONIALS ───────────────────────────────── */}
        <section className="py-24 bg-white border-t border-gray-100">
          <div className="max-w-7xl mx-auto px-5 sm:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-6 mb-16">
              <div>
                <p className="text-xs font-bold tracking-[0.2em] uppercase text-violet-600 mb-3">Reviews</p>
                <h2 className="text-[clamp(2.2rem,5vw,3.8rem)] font-black leading-tight tracking-tight text-black">
                  Loved by<br/>travelers
                </h2>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex -space-x-2">
                  {TESTIMONIALS.map((t, i) => (
                    <img key={i} src={t.avatar} alt={t.name} className="w-9 h-9 rounded-full border-2 border-white object-cover" />
                  ))}
                </div>
                <p className="text-gray-500 text-sm">50k+ happy customers</p>
              </div>
            </div>

            <div className="grid md:grid-cols-3 gap-5">
              {TESTIMONIALS.map((t, i) => (
                <div
                  key={i}
                  className={`rounded-2xl p-7 border ${i === 1 ? 'bg-violet-600 border-violet-600' : 'bg-gray-50 border-gray-100'}`}
                >
                  <div className="flex gap-1 mb-5">
                    {Array.from({ length: t.rating }).map((_, j) => (
                      <Star key={j} className={`w-4 h-4 fill-current ${i === 1 ? 'text-yellow-400' : 'text-yellow-400'}`} />
                    ))}
                  </div>
                  <p className={`text-base leading-relaxed mb-7 ${i === 1 ? 'text-white' : 'text-gray-800'}`}>
                    "{t.text}"
                  </p>
                  <div className="flex items-center gap-3 pt-5 border-t border-current/10">
                    <img src={t.avatar} alt={t.name} className="w-10 h-10 rounded-full object-cover" />
                    <div>
                      <p className={`font-bold text-sm ${i === 1 ? 'text-white' : 'text-black'}`}>{t.name}</p>
                      <p className={`text-xs ${i === 1 ? 'text-violet-200' : 'text-gray-500'}`}>{t.location}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── CTA BAND ───────────────────────────────────── */}
        <section className="bg-yellow-400 py-20">
          <div className="max-w-7xl mx-auto px-5 sm:px-8 flex flex-col lg:flex-row items-center justify-between gap-8">
            <div>
              <h2 className="text-[clamp(2rem,4vw,3.2rem)] font-black tracking-tight text-black leading-tight">
                Ready to explore<br/>with confidence?
              </h2>
              <p className="text-black/60 mt-3 text-base max-w-lg">
                Get your quote in under 2 minutes. No spam, no pressure — just proper protection.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-3 flex-shrink-0">
              <a
                href="/insurance/quote"
                className="inline-flex items-center justify-center gap-2 bg-black text-white text-base font-bold px-8 py-4 rounded-2xl hover:bg-violet-700 transition-colors"
              >
                Get Your Free Quote <ArrowRight className="w-5 h-5" />
              </a>
            </div>
          </div>
        </section>

        {/* ── FOOTER ─────────────────────────────────────── */}
        <footer className="bg-black text-white py-16">
          <div className="max-w-7xl mx-auto px-5 sm:px-8">
            <div className="grid md:grid-cols-[2fr_1fr_1fr_1fr] gap-12 mb-12">
              <div>
                <div className="flex items-center gap-2.5 mb-5">
                  <div className="w-9 h-9 bg-violet-600 rounded-xl flex items-center justify-center">
                    <Shield className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-lg font-black">TravelShield</span>
                </div>
                <p className="text-white/40 text-sm leading-relaxed max-w-xs">
                  Making travel insurance simple, fast, and actually useful. Since 2024.
                </p>
              </div>

              {[
                { title: 'Coverage', links: ['Travel Medical', 'Trip Cancellation', 'Adventure Sports', 'Annual Plans'] },
                { title: 'Company', links: ['About Us', 'Careers', 'Press', 'Contact'] },
                { title: 'Legal', links: ['Privacy Policy', 'Terms of Service', 'Cookie Policy'] },
              ].map(col => (
                <div key={col.title}>
                  <h4 className="text-sm font-bold text-white/40 uppercase tracking-widest mb-5">{col.title}</h4>
                  <ul className="space-y-3">
                    {col.links.map(link => (
                      <li key={link}>
                        <a href="#" className="text-sm text-white/60 hover:text-white transition-colors">{link}</a>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>

            <div className="pt-8 border-t border-white/8 flex flex-col sm:flex-row justify-between items-center gap-4 text-xs text-white/30">
              <p>© 2024 TravelShield. All rights reserved.</p>
              <p>Built for adventurers, by adventurers.</p>
            </div>
          </div>
        </footer>
      </div>
    </>
  )
}
