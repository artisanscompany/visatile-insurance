import { useState, useMemo } from 'react'
import { Loader2, Plus, Trash2, Calendar, MapPin, Plane } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useInsuranceFlow, type QuoteFormData } from '@/contexts/InsuranceFlowContext'
import { SearchableSelect, type SearchableSelectOption } from '@/components/ui/searchable-select'
import { COUNTRIES } from '@/data/countries'
import { LOCALITY_COVERAGES } from '@/data/localities'
import { TRAVEL_TYPES } from '@/data/travel-types'
import { COVERAGE_TIERS } from '@/data/coverage'

export function QuoteFormPanel() {
  const { state, submitQuote } = useInsuranceFlow()

  const [formData, setFormData] = useState<QuoteFormData>(
    state.quoteFormData || {
      start_date: '',
      end_date: '',
      departure_country: '',
      destination_countries: '',
      coverage_tier: 1,
      traveler_birth_dates: [''],
      locality_coverage: 207,
      type_of_travel: 1,
    }
  )

  const countryOptions: SearchableSelectOption[] = useMemo(
    () => COUNTRIES.map(c => ({ value: c.code, label: `${c.name} (${c.code})` })),
    []
  )

  const localityOptions: SearchableSelectOption[] = useMemo(
    () => LOCALITY_COVERAGES.map(l => ({ value: String(l.id), label: l.name })),
    []
  )

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    submitQuote(formData)
  }

  const updateField = <K extends keyof QuoteFormData>(field: K, value: QuoteFormData[K]) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const addTraveler = () => {
    setFormData(prev => ({
      ...prev,
      traveler_birth_dates: [...prev.traveler_birth_dates, ''],
    }))
  }

  const removeTraveler = (index: number) => {
    setFormData(prev => ({
      ...prev,
      traveler_birth_dates: prev.traveler_birth_dates.filter((_, i) => i !== index),
    }))
  }

  const updateBirthDate = (index: number, value: string) => {
    setFormData(prev => {
      const updated = [...prev.traveler_birth_dates]
      updated[index] = value
      return { ...prev, traveler_birth_dates: updated }
    })
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-xl font-black text-black tracking-tight">Get a Quote</h2>
        <p className="text-sm text-gray-500 mt-1">Enter your trip details for an instant price.</p>
      </div>

      {state.error && (
        <div className="rounded-xl bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {state.error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-5">
        {/* Trip Dates */}
        <div className="space-y-3">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Trip Dates</p>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <label htmlFor="panel_start_date" className="flex items-center gap-1.5 text-xs font-semibold text-gray-600">
                <Calendar className="w-3 h-3" /> Departure
              </label>
              <input
                id="panel_start_date"
                type="date"
                value={formData.start_date}
                onChange={e => updateField('start_date', e.target.value)}
                required
                className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
              />
            </div>
            <div className="space-y-1.5">
              <label htmlFor="panel_end_date" className="flex items-center gap-1.5 text-xs font-semibold text-gray-600">
                <Calendar className="w-3 h-3" /> Return
              </label>
              <input
                id="panel_end_date"
                type="date"
                value={formData.end_date}
                onChange={e => updateField('end_date', e.target.value)}
                min={formData.start_date}
                required
                className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
              />
            </div>
          </div>
        </div>

        {/* Countries */}
        <div className="space-y-3">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Countries</p>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <label className="flex items-center gap-1.5 text-xs font-semibold text-gray-600">
                <MapPin className="w-3 h-3" /> From
              </label>
              <SearchableSelect
                value={formData.departure_country}
                onValueChange={v => updateField('departure_country', v)}
                options={countryOptions}
                placeholder="Country..."
                searchPlaceholder="Search countries..."
              />
            </div>
            <div className="space-y-1.5">
              <label className="flex items-center gap-1.5 text-xs font-semibold text-gray-600">
                <MapPin className="w-3 h-3" /> Destination
              </label>
              <SearchableSelect
                value={String(formData.locality_coverage)}
                onValueChange={v => updateField('locality_coverage', Number(v))}
                options={localityOptions}
                placeholder="Region..."
                searchPlaceholder="Search destinations..."
              />
            </div>
          </div>
        </div>

        {/* Travel Type */}
        <div className="space-y-3">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">
            <Plane className="w-3 h-3 inline mr-1" />Travel Type
          </p>
          <div className="grid grid-cols-4 gap-1.5">
            {TRAVEL_TYPES.map(tt => (
              <button
                key={tt.id}
                type="button"
                onClick={() => updateField('type_of_travel', tt.id)}
                className={cn(
                  'relative rounded-xl border-2 px-2 py-2.5 text-left transition-all',
                  formData.type_of_travel === tt.id
                    ? 'border-yellow-400 bg-yellow-50'
                    : 'border-gray-200 hover:border-gray-300'
                )}
              >
                <div className="text-[0.7rem] font-bold text-black leading-tight">{tt.label}</div>
                {formData.type_of_travel === tt.id && (
                  <div className="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full bg-yellow-400" />
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Coverage Tier */}
        <div className="space-y-3">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Coverage</p>
          <div className="grid grid-cols-4 gap-2">
            {COVERAGE_TIERS.map(tier => (
              <button
                key={tier.id}
                type="button"
                onClick={() => updateField('coverage_tier', tier.id)}
                className={cn(
                  'relative rounded-xl border-2 p-3 text-left transition-all',
                  formData.coverage_tier === tier.id
                    ? 'border-yellow-400 bg-yellow-50'
                    : 'border-gray-200 hover:border-gray-300'
                )}
              >
                <div className="text-sm font-bold text-black">{tier.label}</div>
                <div className="text-[0.65rem] text-gray-500 mt-0.5">{tier.limit}</div>
                {formData.coverage_tier === tier.id && (
                  <div className="absolute top-2 right-2 w-2 h-2 rounded-full bg-yellow-400" />
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Travelers */}
        <div className="space-y-3">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Travelers</p>
          {formData.traveler_birth_dates.map((bd, i) => (
            <div key={i} className="flex items-end gap-2">
              <div className="flex-1 space-y-1.5">
                <label className="text-xs font-semibold text-gray-600">
                  Traveler {i + 1} — Date of Birth
                </label>
                <input
                  type="date"
                  value={bd}
                  onChange={e => updateBirthDate(i, e.target.value)}
                  required
                  className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
              {formData.traveler_birth_dates.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeTraveler(i)}
                  className="h-10 w-10 flex items-center justify-center rounded-xl border border-gray-200 text-gray-400 hover:text-red-500 hover:border-red-200 transition-colors shrink-0"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
            onClick={addTraveler}
            className="flex items-center gap-1.5 text-xs font-semibold text-gray-500 hover:text-black transition-colors"
          >
            <Plus className="w-3.5 h-3.5" /> Add traveler
          </button>
        </div>

        {/* Submit */}
        <button
          type="submit"
          disabled={state.processing}
          className="w-full h-12 bg-black hover:bg-yellow-400 text-white hover:text-black font-bold text-sm rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
        >
          {state.processing ? (
            <>
              <Loader2 className="w-4 h-4 animate-spin" />
              Getting quote...
            </>
          ) : (
            'Get My Quote'
          )}
        </button>
      </form>
    </div>
  )
}
