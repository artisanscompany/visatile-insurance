import { useState } from 'react'
import { ArrowLeft, CreditCard, Loader2, Shield } from 'lucide-react'
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

export function CheckoutPanel() {
  const { state, submitCheckout, goBack } = useInsuranceFlow()
  const { quoteRequest, quoteResponse, travelers, quoteFormData } = state
  const [email, setEmail] = useState('')

  if (!quoteResponse || !quoteRequest || !travelers) return null

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    submitCheckout(email)
  }

  const formatDate = (dateStr: string) => {
    return new Date(dateStr + 'T00:00:00').toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
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
        <h2 className="text-xl font-black text-black tracking-tight">Checkout</h2>
        <p className="text-sm text-gray-500 mt-1">Review your order and pay securely.</p>
      </div>

      {state.error && (
        <div className="rounded-xl bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {state.error}
        </div>
      )}

      {/* Order summary */}
      <div className="space-y-3 divide-y divide-gray-100">
        <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Order Summary</p>
        {[
          { label: 'Dates', value: `${formatDate(quoteResponse.start_date)} – ${formatDate(quoteResponse.end_date)}` },
          { label: 'From', value: departureDisplay },
          { label: 'Destination', value: destinationDisplay },
          ...(travelTypeDisplay ? [{ label: 'Travel Type', value: travelTypeDisplay }] : []),
          { label: 'Coverage', value: coverageLabel },
          { label: 'Travelers', value: `${travelers.length} ${travelers.length === 1 ? 'person' : 'people'}` },
        ].map(row => (
          <div key={row.label} className="flex justify-between items-center pt-3 first:pt-0">
            <span className="text-sm text-gray-500">{row.label}</span>
            <span className="text-sm font-semibold text-black">{row.value}</span>
          </div>
        ))}

        <div className="flex justify-between items-baseline pt-4">
          <span className="text-base font-black text-black">Total</span>
          <span className="text-2xl font-black text-black">
            {quoteResponse.price_currency} {quoteResponse.price_amount}
          </span>
        </div>
      </div>

      {/* Email + Pay */}
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="space-y-1.5">
          <label htmlFor="panel_email" className="text-xs font-semibold text-gray-600">
            Email Address
          </label>
          <input
            id="panel_email"
            type="email"
            placeholder="you@example.com"
            value={email}
            onChange={e => setEmail(e.target.value)}
            autoComplete="email"
            required
            className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
          <p className="text-[0.65rem] text-gray-400">We'll send your policy confirmation here.</p>
        </div>

        <div className="flex gap-3">
          <button
            type="button"
            onClick={goBack}
            className="h-11 px-4 rounded-xl border-2 border-gray-200 text-sm font-bold text-gray-600 hover:border-gray-300 transition-colors flex items-center justify-center gap-2"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
          <button
            type="submit"
            disabled={state.processing}
            className="flex-1 h-11 rounded-xl bg-black text-white text-sm font-bold hover:bg-yellow-400 hover:text-black transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {state.processing ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Processing...
              </>
            ) : (
              <>
                <CreditCard className="w-4 h-4" />
                Pay with Stripe
              </>
            )}
          </button>
        </div>

        <div className="flex items-center justify-center gap-1.5 text-[0.65rem] text-gray-400">
          <Shield className="w-3 h-3" />
          <span>Secure payment via Stripe</span>
        </div>
      </form>
    </div>
  )
}
