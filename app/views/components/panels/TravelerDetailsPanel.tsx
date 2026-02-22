import { useState, useMemo } from 'react'
import { ArrowLeft, User } from 'lucide-react'
import { useInsuranceFlow, type TravelerEntry } from '@/contexts/InsuranceFlowContext'
import { SearchableSelect, type SearchableSelectOption } from '@/components/ui/searchable-select'
import { COUNTRIES } from '@/data/countries'

export function TravelerDetailsPanel() {
  const { state, saveTravelers, goBack } = useInsuranceFlow()
  const travelerCount = state.quoteResponse?.traveler_count || 1
  const birthDates = state.quoteFormData?.traveler_birth_dates || []

  const [travelers, setTravelers] = useState<TravelerEntry[]>(() => {
    if (state.travelers) return state.travelers
    return Array.from({ length: travelerCount }, (_, i) => ({
      first_name: '',
      last_name: '',
      birth_date: birthDates[i] || '',
      passport_number: '',
      passport_country: '',
    }))
  })

  const countryOptions: SearchableSelectOption[] = useMemo(
    () => COUNTRIES.map(c => ({ value: c.code, label: `${c.name} (${c.code})` })),
    []
  )

  const updateTraveler = (index: number, field: keyof TravelerEntry, value: string) => {
    setTravelers(prev => {
      const updated = [...prev]
      updated[index] = { ...updated[index], [field]: value }
      return updated
    })
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    saveTravelers(travelers)
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-xl font-black text-black tracking-tight">Traveler Details</h2>
        <p className="text-sm text-gray-500 mt-1">
          {travelerCount === 1 ? 'Enter your passport details.' : `Enter details for all ${travelerCount} travelers.`}
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-5">
        {travelers.map((traveler, i) => (
          <div key={i} className="space-y-3 pb-5 border-b border-gray-200 last:border-0 last:pb-0">
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-lg bg-yellow-400/20 flex items-center justify-center">
                <User className="w-3.5 h-3.5 text-yellow-600" />
              </div>
              <span className="text-sm font-bold text-black">Traveler {i + 1}</span>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-gray-600">First Name</label>
                <input
                  type="text"
                  placeholder="John"
                  value={traveler.first_name}
                  onChange={e => updateTraveler(i, 'first_name', e.target.value)}
                  required
                  className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-gray-600">Last Name</label>
                <input
                  type="text"
                  placeholder="Doe"
                  value={traveler.last_name}
                  onChange={e => updateTraveler(i, 'last_name', e.target.value)}
                  required
                  className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-gray-600">Date of Birth</label>
              <input
                type="date"
                value={traveler.birth_date}
                onChange={e => updateTraveler(i, 'birth_date', e.target.value)}
                required
                className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-gray-600">Passport Number</label>
                <input
                  type="text"
                  placeholder="AB1234567"
                  value={traveler.passport_number}
                  onChange={e => updateTraveler(i, 'passport_number', e.target.value)}
                  required
                  className="w-full h-10 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-gray-600">Passport Country</label>
                <SearchableSelect
                  value={traveler.passport_country}
                  onValueChange={v => updateTraveler(i, 'passport_country', v)}
                  options={countryOptions}
                  placeholder="Country..."
                  searchPlaceholder="Search countries..."
                />
              </div>
            </div>
          </div>
        ))}

        <div className="flex gap-3 pt-2">
          <button
            type="button"
            onClick={goBack}
            className="flex-1 h-11 rounded-xl border-2 border-gray-200 text-sm font-bold text-gray-600 hover:border-gray-300 transition-colors flex items-center justify-center gap-2"
          >
            <ArrowLeft className="w-4 h-4" /> Back
          </button>
          <button
            type="submit"
            className="flex-1 h-11 rounded-xl bg-black text-white text-sm font-bold hover:bg-yellow-400 hover:text-black transition-colors flex items-center justify-center gap-2"
          >
            Continue to Payment
          </button>
        </div>
      </form>
    </div>
  )
}
