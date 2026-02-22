import { ArrowLeft, ArrowRight } from 'lucide-react'
import { useInsuranceFlow } from '@/contexts/InsuranceFlowContext'
import { COVERAGE_LABELS } from '@/data/coverage'
import { COUNTRIES } from '@/data/countries'
import { LOCALITY_COVERAGES } from '@/data/localities'
import { TRAVEL_TYPE_MAP } from '@/data/travel-types'

const COUNTRY_MAP: Record<string, string> = Object.fromEntries(
  COUNTRIES.map(c => [c.code, c.name])
)

const LOCALITY_MAP: Record<number, string> = Object.fromEntries(
  LOCALITY_COVERAGES.map(l => [l.id, l.name])
)

export function QuoteReviewPanel() {
  const { state, goToTravelers, goBack } = useInsuranceFlow()
  const { quoteRequest, quoteResponse, quoteFormData } = state

  if (!quoteResponse || !quoteRequest) return null

  const formatDate = (dateStr: string) => {
    return new Date(dateStr + 'T00:00:00').toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }

  const coverageLabel = COVERAGE_LABELS[quoteResponse.coverage_tier] || 'Unknown'

  const departureCountry = String(quoteRequest.departure_country || '')
  const departureDisplay = COUNTRY_MAP[departureCountry] || departureCountry

  const localityCoverage = quoteResponse.locality_coverage || (quoteFormData?.locality_coverage)
  const destinationDisplay = localityCoverage ? (LOCALITY_MAP[localityCoverage] || `Region ${localityCoverage}`) : ''

  const travelType = quoteFormData?.type_of_travel
  const travelTypeDisplay = travelType ? (TRAVEL_TYPE_MAP[travelType] || '') : ''

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-xl font-black text-black tracking-tight">Your Quote</h2>
        <p className="text-sm text-gray-500 mt-1">Review your insurance details.</p>
      </div>

      {/* Price hero */}
      <div className="text-center py-6 rounded-2xl bg-black text-white">
        <p className="text-[0.65rem] font-bold uppercase tracking-[0.2em] text-yellow-400 mb-1">Total Price</p>
        <p className="text-4xl font-black tracking-tight">
          {quoteResponse.price_currency} {quoteResponse.price_amount}
        </p>
        <span className="inline-block mt-2 px-3 py-1 rounded-full bg-white/10 text-yellow-400 text-xs font-bold">
          {coverageLabel} Coverage
        </span>
      </div>

      {/* Details */}
      <div className="space-y-3 divide-y divide-gray-100">
        {[
          { label: 'Plan', value: quoteResponse.tariff_name },
          { label: 'Travel Dates', value: `${formatDate(quoteResponse.start_date)} – ${formatDate(quoteResponse.end_date)}` },
          { label: 'From', value: departureDisplay },
          { label: 'Destination', value: destinationDisplay },
          ...(travelTypeDisplay ? [{ label: 'Travel Type', value: travelTypeDisplay }] : []),
          { label: 'Coverage', value: coverageLabel },
          { label: 'Travelers', value: `${quoteResponse.traveler_count} ${quoteResponse.traveler_count === 1 ? 'person' : 'people'}` },
        ].map(row => (
          <div key={row.label} className="flex justify-between items-center pt-3 first:pt-0">
            <span className="text-sm text-gray-500">{row.label}</span>
            <span className="text-sm font-semibold text-black">{row.value}</span>
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="flex gap-3 pt-2">
        <button
          onClick={goBack}
          className="flex-1 h-11 rounded-xl border-2 border-gray-200 text-sm font-bold text-gray-600 hover:border-gray-300 transition-colors flex items-center justify-center gap-2"
        >
          <ArrowLeft className="w-4 h-4" /> Back
        </button>
        <button
          onClick={goToTravelers}
          className="flex-1 h-11 rounded-xl bg-black text-white text-sm font-bold hover:bg-yellow-400 hover:text-black transition-colors flex items-center justify-center gap-2"
        >
          Continue <ArrowRight className="w-4 h-4" />
        </button>
      </div>
    </div>
  )
}
