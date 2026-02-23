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
  FileText,
  Banknote,
} from 'lucide-react'
import { useState } from 'react'
import { PanelProvider, usePanel } from '@/contexts/PanelContext'
import { InsuranceFlowPanel } from '@/components/panels/InsuranceFlowPanel'
import { LoginPanel } from '@/components/panels/LoginPanel'
import { ConfirmationPanel } from '@/components/panels/ConfirmationPanel'
import { SlidePanel } from '@/components/layout/SlidePanel'

const COVERAGE_ITEMS = [
  {
    icon: HeartPulse,
    title: 'Medical Emergencies',
    description: 'Hospital bills, specialist visits, surgery, and emergency evacuation — covered anywhere on the planet. No caps on emergencies.',
    image: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1000&q=90',
    tag: 'Most claimed',
    stat: 'Up to $500k',
    statLabel: 'medical coverage',
  },
  {
    icon: Plane,
    title: 'Trip Cancellation',
    description: 'Life happens. Recoup 100% of non-refundable trip costs when illness, weather, or anything else forces you to cancel.',
    image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1000&q=90',
    tag: null,
    stat: '100%',
    statLabel: 'reimbursement',
  },
  {
    icon: Luggage,
    title: 'Lost Baggage',
    description: 'Airline lost your bags? You\'re covered for the contents and essentials while you wait — so you\'re never stranded.',
    image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=1000&q=90',
    tag: null,
    stat: '$3,000',
    statLabel: 'baggage limit',
  },
  {
    icon: Clock,
    title: 'Travel Delays',
    description: 'Stuck at the airport? Meals, hotels, and transfers covered from hour one when flights are delayed or cancelled.',
    image: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1000&q=90',
    tag: null,
    stat: 'From hour 1',
    statLabel: 'delay cover kicks in',
  },
  {
    icon: Umbrella,
    title: 'Personal Liability',
    description: 'If you accidentally injure someone or damage property abroad, we\'ve got you covered against legal costs and compensation.',
    image: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=1000&q=90',
    tag: null,
    stat: '$2M',
    statLabel: 'liability cover',
  },
  {
    icon: Shield,
    title: '24/7 Assistance',
    description: 'Real humans answer the phone, day or night. Wherever you are, whatever the crisis — we pick up.',
    image: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=1000&q=90',
    tag: 'Always on',
    stat: '< 2 min',
    statLabel: 'avg. response time',
  },
]

const DESTINATIONS = [
  {
    name: 'Europe',
    countries: '40+ countries',
    image: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=900&q=85',
    highlight: 'Schengen & beyond',
    localityId: 208,
  },
  {
    name: 'Asia Pacific',
    countries: '25+ countries',
    image: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=900&q=85',
    highlight: 'From Bali to Tokyo',
    localityId: 207,
  },
  {
    name: 'The Americas',
    countries: '35+ countries',
    image: 'https://images.unsplash.com/photo-1518391846015-55a9cc003b25?w=900&q=85',
    highlight: 'North to South',
    localityId: 207,
  },
  {
    name: 'Africa & Middle East',
    countries: '30+ countries',
    image: 'https://images.unsplash.com/photo-1489392191049-fc10c97e64b6?w=900&q=85',
    highlight: 'Wild & wonderful',
    localityId: 207,
  },
]

const ACTIVITIES = [
  { name: 'Beach & Water Sports', icon: Waves, image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=700&q=85', travelTypeId: 2 },
  { name: 'Hiking & Trekking', icon: Mountain, image: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=700&q=85', travelTypeId: 2 },
  { name: 'Winter Sports', icon: Mountain, image: 'https://images.unsplash.com/photo-1551524559-8af4e6624178?w=700&q=85', travelTypeId: 3 },
  { name: 'Cycling Tours', icon: Bike, image: 'https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=700&q=85', travelTypeId: 2 },
  { name: 'Sailing & Boating', icon: Sailboat, image: 'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=700&q=85', travelTypeId: 2 },
  { name: 'Camping & Outdoor', icon: Tent, image: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=700&q=85', travelTypeId: 2 },
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
    text: 'Our honeymoon got disrupted by a storm. TravelsKit sorted us out within 24 hours. Absolute lifesavers.',
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

const TICKER_ITEMS = ['Medical Coverage', 'Trip Cancellation', 'Lost Baggage', 'Flight Delays', 'Personal Liability', '24/7 Assistance']

type LandingPageProps = {
  panel?: string | null
  panel_params?: Record<string, string>
}

export default function LandingPage({ panel, panel_params }: LandingPageProps) {
  return (
    <PanelProvider initialPanel={panel} initialParams={panel_params || {}}>
      <LandingContent />
    </PanelProvider>
  )
}

function LandingContent() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const { activePanel, panelParams, openPanel, closePanel } = usePanel()

  return (
    <>
      <Head title="TravelsKit — Travel Insurance Made Simple" />

      <div className="min-h-screen bg-[#fafaf8] font-sans scroll-smooth">

        {/* ── HEADER ─────────────────────────────────────── */}
        <header className="fixed top-0 left-0 right-0 z-50 bg-[#fafaf8]/90 backdrop-blur-md border-b border-black/8">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16 sm:h-[68px]">
              <a href="/" className="flex items-center gap-2 sm:gap-2.5 group">
                <div className="w-8 h-8 sm:w-9 sm:h-9 bg-black rounded-xl flex items-center justify-center group-hover:bg-yellow-400 transition-colors">
                  <Shield className="w-4 h-4 sm:w-5 sm:h-5 text-white group-hover:text-black transition-colors" />
                </div>
                <span className="text-base sm:text-[1.1rem] font-bold tracking-tight text-black">TravelsKit</span>
              </a>

              <nav className="hidden md:flex items-center gap-5 lg:gap-7">
                {['Coverage', 'Destinations', 'Activities', 'Claims'].map(item => (
                  <a
                    key={item}
                    href={`#${item.toLowerCase()}`}
                    className="text-sm font-medium text-gray-500 hover:text-black transition-colors"
                  >
                    {item}
                  </a>
                ))}
                <div className="w-px h-4 bg-gray-300" />
                <button onClick={() => openPanel('login')} className="text-sm font-medium text-gray-500 hover:text-black transition-colors">
                  Login
                </button>
                <button
                  onClick={() => openPanel('quote')}
                  className="inline-flex items-center gap-1.5 bg-black text-white text-sm font-semibold px-4 py-2 rounded-xl hover:bg-yellow-400 hover:text-black transition-colors"
                >
                  Get a Quote <ArrowUpRight className="w-3.5 h-3.5" />
                </button>
              </nav>

              <button className="md:hidden p-2 -mr-2" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
                {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
              </button>
            </div>
          </div>

          {mobileMenuOpen && (
            <div className="md:hidden bg-[#fafaf8] border-t border-black/8 px-4 py-4 space-y-1">
              {['Coverage', 'Destinations', 'Activities', 'Claims'].map(item => (
                <a key={item} href={`#${item.toLowerCase()}`} className="block py-2.5 text-sm font-medium text-gray-700">
                  {item}
                </a>
              ))}
              <button onClick={() => { openPanel('login'); setMobileMenuOpen(false) }} className="block w-full text-left py-2.5 text-sm font-medium text-gray-700">Login</button>
              <div className="pt-2">
                <button onClick={() => { openPanel('quote'); setMobileMenuOpen(false) }} className="block w-full text-center bg-black text-white text-sm font-semibold px-4 py-3 rounded-xl">
                  Get a Quote
                </button>
              </div>
            </div>
          )}
        </header>

        {/* ── HERO ───────────────────────────────────────── */}
        <section className="relative min-h-screen flex flex-col pt-16 sm:pt-[68px] overflow-hidden bg-black">
          {/* Full bleed image */}
          <div className="absolute inset-0">
            <img
              src="https://images.unsplash.com/photo-1488085061387-422e29b40080?w=1920&q=90"
              alt="Aerial view of airplane wing at sunset"
              className="w-full h-full object-cover opacity-50"
            />
          </div>

          {/* Grain texture overlay */}
          <div
            className="absolute inset-0 z-[2] pointer-events-none mix-blend-overlay opacity-[0.04]"
            style={{
              backgroundImage: 'repeating-conic-gradient(#fff 0% 25%, transparent 0% 50%)',
              backgroundSize: '3px 3px',
            }}
          />

          {/* Content */}
          <div className="relative z-10 flex-1 flex flex-col justify-between max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8 sm:py-16">
            {/* Top badge */}
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-1.5 bg-white/10 border border-white/20 rounded-full px-3 py-1.5 sm:px-3.5">
                {[1,2,3,4,5].map(i => <Star key={i} className="w-3 h-3 text-yellow-400 fill-yellow-400" />)}
                <span className="text-white text-[0.7rem] sm:text-xs font-medium ml-1">50,000+ travelers trust us</span>
              </div>
            </div>

            {/* Big headline + CTA */}
            <div className="max-w-3xl space-y-6 sm:space-y-8">
              <h1 className="text-[clamp(2.6rem,8vw,7rem)] leading-[0.92] tracking-tight text-white">
                <span className="font-serif italic">Adventure</span><br/>
                <span className="font-black text-yellow-400">awaits.</span><br/>
                <span className="font-black">We've got</span><br/>
                <span className="font-black">you.</span>
              </h1>

              <p className="text-base sm:text-lg text-white/70 max-w-md leading-relaxed">
                Travel insurance that's genuinely simple — covered in minutes, claim in clicks.
              </p>

              <div className="flex flex-col sm:flex-row sm:items-center gap-4">
                <button
                  onClick={() => openPanel('quote')}
                  className="inline-flex items-center justify-center gap-2.5 bg-yellow-400 text-black text-base font-bold px-8 py-4 rounded-2xl hover:bg-yellow-300 transition-colors w-full sm:w-auto"
                >
                  Get Your Free Quote <ArrowRight className="w-5 h-5" />
                </button>
                <a
                  href="#coverage"
                  className="inline-flex items-center justify-center sm:justify-start gap-2 text-white/70 text-sm font-medium hover:text-white transition-colors"
                >
                  See what's covered <ArrowRight className="w-4 h-4" />
                </a>
              </div>

              <div className="flex flex-wrap gap-x-5 gap-y-2 sm:gap-x-6">
                {['No hidden fees', 'Instant coverage', 'Global 24/7 support'].map(f => (
                  <div key={f} className="flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4 text-yellow-400 shrink-0" />
                    <span className="text-white/80 text-sm">{f}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Animated ticker */}
          <div className="relative z-10 border-t border-white/10 bg-white/5 backdrop-blur-sm overflow-hidden">
            <div className="flex animate-[marquee_25s_linear_infinite]">
              {[...TICKER_ITEMS, ...TICKER_ITEMS, ...TICKER_ITEMS].map((item, i) => (
                <span key={i} className="text-white/50 text-[0.65rem] sm:text-xs font-medium tracking-widest uppercase whitespace-nowrap flex items-center gap-4 sm:gap-6 px-3 sm:px-5 py-3">
                  {item}
                  <span className="text-yellow-400 text-lg leading-none">·</span>
                </span>
              ))}
            </div>
          </div>
        </section>

        {/* ── WHAT'S COVERED ─────────────────────────────── */}
        <section id="coverage" className="scroll-mt-16 sm:scroll-mt-[68px] bg-[#fafaf8]">
          {/* Section header */}
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-16 pb-10 sm:pt-24 sm:pb-16">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 sm:gap-6">
              <div>
                <p className="text-base sm:text-lg font-serif italic text-yellow-500 mb-2 sm:mb-3">Protection</p>
                <h2 className="text-[clamp(2.2rem,6vw,4.5rem)] font-black leading-[0.9] tracking-tight text-black">
                  What's<br/>covered
                </h2>
              </div>
              <p className="text-gray-500 max-w-sm text-sm sm:text-base leading-relaxed sm:text-right">
                Every plan covers you from minor headaches to full-blown emergencies.
              </p>
            </div>
          </div>

          {/* Alternating editorial rows */}
          <div className="divide-y divide-gray-200 border-t border-gray-200">
            {COVERAGE_ITEMS.map((item, i) => {
              const isEven = i % 2 === 0
              const isYellowIcon = i % 2 === 0
              const iconBg = isYellowIcon ? 'bg-yellow-400' : 'bg-black'
              const iconText = isYellowIcon ? 'text-black' : 'text-white'
              const statColor = isYellowIcon ? 'text-yellow-500' : 'text-black'

              return (
                <div key={i} className="group overflow-hidden">
                  <div className={`grid lg:grid-cols-2 ${isEven ? '' : 'lg:grid-flow-col-dense'}`}>
                    {/* Image side */}
                    <div className={`relative overflow-hidden h-48 sm:h-64 lg:h-80 ${isEven ? '' : 'lg:col-start-2'}`}>
                      <img
                        src={item.image}
                        alt={item.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                      />
                      <div className={`absolute inset-0 ${iconBg} opacity-20 mix-blend-multiply`} />
                      {item.tag && (
                        <div className="absolute top-3 left-3 sm:top-4 sm:left-4 bg-yellow-400 text-black text-[0.6rem] sm:text-[0.65rem] font-black uppercase tracking-[0.15em] px-2.5 py-1 sm:px-3 sm:py-1.5 rounded-full">
                          {item.tag}
                        </div>
                      )}
                    </div>

                    {/* Text side */}
                    <div className={`flex flex-col justify-center px-4 py-8 sm:px-8 sm:py-12 lg:px-16 bg-white ${isEven ? '' : 'lg:col-start-1 lg:row-start-1'}`}>
                      {/* Number + icon row */}
                      <div className="flex items-center gap-3 sm:gap-4 mb-4 sm:mb-6">
                        <span className="text-4xl sm:text-5xl font-serif text-yellow-400/20 leading-none tracking-tight">
                          {String(i + 1).padStart(2, '0')}
                        </span>
                        <div className={`w-8 h-8 sm:w-9 sm:h-9 rounded-xl flex items-center justify-center ${iconBg} ${iconText}`}>
                          <item.icon className="w-4 h-4 sm:w-4.5 sm:h-4.5" />
                        </div>
                        <div className="flex-1 h-px bg-gray-100" />
                      </div>

                      <h3 className="text-xl sm:text-2xl lg:text-3xl font-black text-black mb-2 sm:mb-3 leading-tight tracking-tight">
                        {item.title}
                      </h3>
                      <p className="text-gray-500 text-sm sm:text-base leading-relaxed mb-6 sm:mb-8 max-w-sm">
                        {item.description}
                      </p>

                      {/* Big stat */}
                      <div className="flex items-baseline gap-2 sm:gap-3 pt-5 sm:pt-6 border-t border-gray-100">
                        <span className={`text-2xl sm:text-3xl font-black tracking-tight ${statColor}`}>
                          {item.stat}
                        </span>
                        <span className="text-xs sm:text-sm text-gray-400 uppercase tracking-wider font-medium">{item.statLabel}</span>
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </section>

        {/* ── DESTINATIONS ───────────────────────────────── */}
        <section id="destinations" className="scroll-mt-16 sm:scroll-mt-[68px] py-16 sm:py-24 bg-black text-white relative overflow-hidden">
          {/* Grain texture */}
          <div
            className="absolute inset-0 pointer-events-none mix-blend-overlay opacity-[0.03]"
            style={{
              backgroundImage: 'repeating-conic-gradient(#fff 0% 25%, transparent 0% 50%)',
              backgroundSize: '3px 3px',
            }}
          />

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 sm:gap-6 mb-10 sm:mb-16">
              <div>
                <p className="text-base sm:text-lg font-serif italic text-yellow-400 mb-2 sm:mb-3">Worldwide</p>
                <h2 className="text-[clamp(2rem,5vw,3.8rem)] font-black leading-tight tracking-tight">
                  Destinations<br/>covered
                </h2>
              </div>
              <p className="text-white/50 max-w-sm text-sm sm:text-base leading-relaxed">
                130+ countries. Every continent. One policy.
              </p>
            </div>

            {/* Bold grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-[1fr_1fr_320px] gap-3 sm:gap-4">
              {/* First large card */}
              <div onClick={() => openPanel('quote', { locality_coverage: String(DESTINATIONS[0].localityId) })} className="group relative rounded-2xl overflow-hidden h-64 sm:h-80 lg:h-auto cursor-pointer border border-white/5 hover:border-yellow-400/30 transition-colors duration-500">
                <img
                  src={DESTINATIONS[0].image}
                  alt={DESTINATIONS[0].name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/50 transition-colors duration-300" />
                <div className="absolute bottom-4 left-4 right-4 sm:bottom-6 sm:left-6 sm:right-6">
                  <p className="text-yellow-400 text-[0.65rem] sm:text-xs font-bold uppercase tracking-widest mb-0.5 sm:mb-1">{DESTINATIONS[0].highlight}</p>
                  <h3 className="text-2xl sm:text-3xl font-black text-white">{DESTINATIONS[0].name}</h3>
                  <p className="text-white/60 text-xs sm:text-sm mt-0.5 sm:mt-1">{DESTINATIONS[0].countries}</p>
                </div>
              </div>

              {/* Second large card */}
              <div onClick={() => openPanel('quote', { locality_coverage: String(DESTINATIONS[1].localityId) })} className="group relative rounded-2xl overflow-hidden h-64 sm:h-80 lg:h-auto cursor-pointer border border-white/5 hover:border-yellow-400/30 transition-colors duration-500">
                <img
                  src={DESTINATIONS[1].image}
                  alt={DESTINATIONS[1].name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/50 transition-colors duration-300" />
                <div className="absolute bottom-4 left-4 right-4 sm:bottom-6 sm:left-6 sm:right-6">
                  <p className="text-yellow-400 text-[0.65rem] sm:text-xs font-bold uppercase tracking-widest mb-0.5 sm:mb-1">{DESTINATIONS[1].highlight}</p>
                  <h3 className="text-2xl sm:text-3xl font-black text-white">{DESTINATIONS[1].name}</h3>
                  <p className="text-white/60 text-xs sm:text-sm mt-0.5 sm:mt-1">{DESTINATIONS[1].countries}</p>
                </div>
              </div>

              {/* Two stacked smaller cards */}
              <div className="grid grid-cols-2 sm:col-span-2 lg:col-span-1 lg:grid-cols-1 gap-3 sm:gap-4">
                {DESTINATIONS.slice(2).map((d, i) => (
                  <div key={i} onClick={() => openPanel('quote', { locality_coverage: String(d.localityId) })} className="group relative rounded-2xl overflow-hidden h-44 sm:h-48 lg:h-auto lg:flex-1 cursor-pointer border border-white/5 hover:border-yellow-400/30 transition-colors duration-500">
                    <img
                      src={d.image}
                      alt={d.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                    />
                    <div className="absolute inset-0 bg-black/45 group-hover:bg-black/55 transition-colors duration-300" />
                    <div className="absolute bottom-3 left-3 right-3 sm:bottom-4 sm:left-4 sm:right-4">
                      <p className="text-yellow-400 text-[0.6rem] sm:text-[0.65rem] font-bold uppercase tracking-widest mb-0.5">{d.highlight}</p>
                      <h3 className="text-base sm:text-lg font-black text-white">{d.name}</h3>
                      <p className="text-white/60 text-[0.65rem] sm:text-xs mt-0.5">{d.countries}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* ── ACTIVITIES ─────────────────────────────────── */}
        <section id="activities" className="scroll-mt-16 sm:scroll-mt-[68px] py-16 sm:py-24 bg-[#fafaf8]">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 sm:gap-6 mb-10 sm:mb-16">
              <div>
                <p className="text-base sm:text-lg font-serif italic text-yellow-500 mb-2 sm:mb-3">Adventure</p>
                <h2 className="text-[clamp(2rem,5vw,3.8rem)] font-black leading-tight tracking-tight text-black">
                  Activities<br/>covered
                </h2>
              </div>
              <p className="text-gray-500 max-w-sm text-sm sm:text-base leading-relaxed">
                Thrill-seeker or beach lover — your activities are protected.
              </p>
            </div>

            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
              {ACTIVITIES.map((activity, i) => (
                <div
                  key={i}
                  onClick={() => openPanel('quote', { type_of_travel: String(activity.travelTypeId) })}
                  className="group relative rounded-xl sm:rounded-2xl overflow-hidden cursor-pointer h-44 sm:h-56 lg:h-72"
                >
                  <img
                    src={activity.image}
                    alt={activity.name}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                  />
                  <div className="absolute inset-0 bg-black/30 group-hover:bg-black/45 transition-colors duration-300" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent" />

                  {/* Icon chip */}
                  <div className="absolute top-2.5 left-2.5 sm:top-4 sm:left-4 w-8 h-8 sm:w-10 sm:h-10 bg-yellow-400/20 backdrop-blur-md rounded-lg sm:rounded-xl flex items-center justify-center border border-yellow-400/30 group-hover:bg-yellow-400 group-hover:border-yellow-400 transition-colors duration-300">
                    <activity.icon className="w-4 h-4 sm:w-5 sm:h-5 text-white group-hover:text-black transition-colors duration-300" />
                  </div>

                  {/* Label bottom */}
                  <div className="absolute bottom-3 left-3 right-3 sm:bottom-5 sm:left-5 sm:right-5">
                    <h3 className="text-sm sm:text-base lg:text-lg font-bold text-white leading-tight">{activity.name}</h3>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── TESTIMONIALS ───────────────────────────────── */}
        <section className="py-16 sm:py-24 bg-white border-t border-gray-100">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 sm:gap-6 mb-10 sm:mb-16">
              <div>
                <p className="text-base sm:text-lg font-serif italic text-yellow-500 mb-2 sm:mb-3">Reviews</p>
                <h2 className="text-[clamp(2rem,5vw,3.8rem)] font-black leading-tight tracking-tight text-black">
                  Loved by<br/>travelers
                </h2>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex -space-x-2">
                  {TESTIMONIALS.map((t, i) => (
                    <img key={i} src={t.avatar} alt={t.name} className="w-8 h-8 sm:w-9 sm:h-9 rounded-full border-2 border-white object-cover" />
                  ))}
                </div>
                <p className="text-gray-500 text-xs sm:text-sm">50k+ happy customers</p>
              </div>
            </div>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
              {TESTIMONIALS.map((t, i) => (
                <div
                  key={i}
                  className={`rounded-2xl p-5 sm:p-7 border relative overflow-hidden ${i === 1 ? 'bg-black border-black' : 'bg-gray-50 border-gray-100'} ${i === 2 ? 'sm:col-span-2 lg:col-span-1' : ''}`}
                >
                  {/* Decorative quote mark on highlighted card */}
                  {i === 1 && (
                    <div className="absolute -top-2 right-3 sm:right-4 text-yellow-400/10 text-[7rem] sm:text-[10rem] font-serif leading-none select-none pointer-events-none">
                      "
                    </div>
                  )}

                  <div className="relative">
                    <div className="flex gap-1 mb-4 sm:mb-5">
                      {Array.from({ length: t.rating }).map((_, j) => (
                        <Star key={j} className="w-3.5 h-3.5 sm:w-4 sm:h-4 fill-current text-yellow-400" />
                      ))}
                    </div>
                    <p className={`text-sm sm:text-base leading-relaxed mb-5 sm:mb-7 ${i === 1 ? 'text-white' : 'text-gray-800'}`}>
                      "{t.text}"
                    </p>
                    <div className={`flex items-center gap-3 pt-4 sm:pt-5 border-t ${i === 1 ? 'border-white/10' : 'border-gray-200'}`}>
                      <img src={t.avatar} alt={t.name} className="w-9 h-9 sm:w-10 sm:h-10 rounded-full object-cover" />
                      <div>
                        <p className={`font-bold text-sm ${i === 1 ? 'text-white' : 'text-black'}`}>{t.name}</p>
                        <p className={`text-xs ${i === 1 ? 'text-yellow-400/60' : 'text-gray-500'}`}>{t.location}</p>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── CLAIMS ─────────────────────────────────────── */}
        <section id="claims" className="scroll-mt-16 sm:scroll-mt-17 py-16 sm:py-24 bg-[#fafaf8] border-t border-gray-100">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 sm:gap-6 mb-10 sm:mb-16">
              <div>
                <p className="text-base sm:text-lg font-serif italic text-yellow-500 mb-2 sm:mb-3">Claims</p>
                <h2 className="text-[clamp(2rem,5vw,3.8rem)] font-black leading-tight tracking-tight text-black">
                  Fast claims,<br/>fair outcomes
                </h2>
              </div>
              <p className="text-gray-500 max-w-sm text-sm sm:text-base leading-relaxed sm:text-right">
                File, track, and get paid — all from your dashboard. No paperwork, no runaround.
              </p>
            </div>

            <div className="grid sm:grid-cols-3 gap-4 sm:gap-5">
              {[
                {
                  icon: FileText,
                  step: '01',
                  title: 'File Online',
                  description: 'Submit your claim through our dashboard in minutes. Upload documents, describe what happened.',
                },
                {
                  icon: Clock,
                  step: '02',
                  title: 'Track Progress',
                  description: 'Real-time updates on your claim status. No more wondering or waiting on hold.',
                },
                {
                  icon: Banknote,
                  step: '03',
                  title: 'Get Paid',
                  description: 'Approved claims paid directly to your bank. Most claims settled within 5 business days.',
                },
              ].map((card, i) => (
                <div key={i} className="group rounded-2xl border border-gray-200 bg-white p-6 sm:p-8 hover:border-yellow-400/50 transition-colors duration-300">
                  <div className="flex items-center gap-3 mb-5 sm:mb-6">
                    <span className="text-3xl sm:text-4xl font-serif text-yellow-400/20 leading-none tracking-tight">{card.step}</span>
                    <div className="w-9 h-9 sm:w-10 sm:h-10 bg-yellow-400 rounded-xl flex items-center justify-center">
                      <card.icon className="w-4 h-4 sm:w-5 sm:h-5 text-black" />
                    </div>
                    <div className="flex-1 h-px bg-gray-100" />
                  </div>
                  <h3 className="text-lg sm:text-xl font-black text-black mb-2 tracking-tight">{card.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed">{card.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── CTA BAND ───────────────────────────────────── */}
        <section className="bg-yellow-400 py-12 sm:py-20 relative overflow-hidden">
          {/* Diagonal stripes texture */}
          <div
            className="absolute inset-0 pointer-events-none opacity-[0.045]"
            style={{
              backgroundImage: 'repeating-linear-gradient(-45deg, transparent, transparent 20px, #000 20px, #000 21px)',
            }}
          />
          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6 sm:gap-8">
            <div>
              <h2 className="text-[clamp(1.8rem,4vw,3.2rem)] font-black tracking-tight text-black leading-tight">
                Ready to explore<br/>with confidence?
              </h2>
              <p className="text-black/60 mt-2 sm:mt-3 text-sm sm:text-base max-w-lg">
                Get your quote in under 2 minutes. No spam, no pressure — just proper protection.
              </p>
            </div>
            <div className="w-full sm:w-auto shrink-0">
              <button
                onClick={() => openPanel('quote')}
                className="inline-flex items-center justify-center gap-2 bg-black text-yellow-400 text-sm sm:text-base font-bold px-6 sm:px-8 py-3.5 sm:py-4 rounded-2xl hover:bg-gray-900 transition-colors w-full sm:w-auto"
              >
                Get Your Free Quote <ArrowRight className="w-5 h-5" />
              </button>
            </div>
          </div>
        </section>

        {/* ── FOOTER ─────────────────────────────────────── */}
        <footer className="bg-black text-white py-12 sm:py-16 relative">
          {/* Yellow accent line */}
          <div className="absolute top-0 left-0 right-0 h-px bg-yellow-400/30" />

          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-2 gap-8 sm:gap-10 lg:grid-cols-[2fr_1fr_1fr_1fr] lg:gap-12 mb-10 sm:mb-12">
              <div className="col-span-2 lg:col-span-1">
                <div className="flex items-center gap-2.5 mb-4 sm:mb-5">
                  <div className="w-8 h-8 sm:w-9 sm:h-9 bg-yellow-400 rounded-xl flex items-center justify-center">
                    <Shield className="w-4 h-4 sm:w-5 sm:h-5 text-black" />
                  </div>
                  <span className="text-base sm:text-lg font-black">TravelsKit</span>
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
                  <h4 className="text-xs sm:text-sm font-bold text-white/40 uppercase tracking-widest mb-3 sm:mb-5">{col.title}</h4>
                  <ul className="space-y-2.5 sm:space-y-3">
                    {col.links.map(link => (
                      <li key={link}>
                        <a href="#" className="text-sm text-white/60 hover:text-yellow-400 transition-colors">{link}</a>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>

            <div className="pt-6 sm:pt-8 border-t border-white/8 flex flex-col sm:flex-row justify-between items-center gap-3 sm:gap-4 text-xs text-white/30">
              <p>© 2025 TravelsKit. All rights reserved. travelskit.com</p>
              <p>Built for adventurers, by adventurers.</p>
            </div>
          </div>
        </footer>
      </div>

      {/* ── PANELS ───────────────────────────────────── */}
      <InsuranceFlowPanel open={activePanel === 'quote'} onClose={closePanel} prefill={panelParams} />

      <SlidePanel open={activePanel === 'login' || activePanel === 'verify'} onClose={closePanel} title="Sign In">
        <LoginPanel initialCode={activePanel === 'verify' ? panelParams.code : undefined} />
      </SlidePanel>

      <SlidePanel open={activePanel === 'confirmation'} onClose={closePanel} title="Confirmed">
        <ConfirmationPanel
          policyId={panelParams.policy_id}
          sessionId={panelParams.session_id}
          onLogin={() => openPanel('login')}
        />
      </SlidePanel>
    </>
  )
}
