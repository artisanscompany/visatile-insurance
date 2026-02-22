import { useState } from 'react'
import { Calendar, MapPin, ArrowRight } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

type QuickQuoteFormData = {
  start_date: string
  end_date: string
  destination: string
}

export function QuickQuote() {
  const [formData, setFormData] = useState<QuickQuoteFormData>({
    start_date: '',
    end_date: '',
    destination: '',
  })

  const handleChange = (field: keyof QuickQuoteFormData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const params = new URLSearchParams({
      start_date: formData.start_date,
      end_date: formData.end_date,
      destination: formData.destination.toUpperCase(),
    })
    window.location.href = `/insurance/quote?${params.toString()}`
  }

  const today = new Date().toISOString().split('T')[0]

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-white/20 p-7 w-full">
      <p className="text-[0.65rem] font-bold uppercase tracking-[0.2em] text-yellow-600 mb-1">Instant quote</p>
      <h3 className="text-xl font-black text-black mb-6 leading-tight">Where are you headed?</h3>

      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-1.5">
            <Label htmlFor="start_date" className="flex items-center gap-1.5 text-[0.7rem] font-bold text-gray-400 uppercase tracking-wider">
              <Calendar className="w-3 h-3" /> Departure
            </Label>
            <Input
              id="start_date"
              type="date"
              value={formData.start_date}
              onChange={e => handleChange('start_date', e.target.value)}
              min={today}
              required
              className="h-11 border-gray-200 text-sm rounded-xl focus-visible:ring-yellow-500 focus-visible:border-yellow-500"
            />
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="end_date" className="flex items-center gap-1.5 text-[0.7rem] font-bold text-gray-400 uppercase tracking-wider">
              <Calendar className="w-3 h-3" /> Return
            </Label>
            <Input
              id="end_date"
              type="date"
              value={formData.end_date}
              onChange={e => handleChange('end_date', e.target.value)}
              min={formData.start_date || today}
              required
              className="h-11 border-gray-200 text-sm rounded-xl focus-visible:ring-yellow-500 focus-visible:border-yellow-500"
            />
          </div>
        </div>

        <div className="space-y-1.5">
          <Label htmlFor="destination" className="flex items-center gap-1.5 text-[0.7rem] font-bold text-gray-400 uppercase tracking-wider">
            <MapPin className="w-3 h-3" /> Destination
          </Label>
          <Input
            id="destination"
            type="text"
            placeholder="FR, IT, ES — country codes"
            value={formData.destination}
            onChange={e => handleChange('destination', e.target.value.toUpperCase())}
            required
            className="h-11 border-gray-200 text-sm rounded-xl focus-visible:ring-yellow-500 focus-visible:border-yellow-500"
          />
        </div>

        <button
          type="submit"
          className="w-full h-12 bg-black hover:bg-yellow-400 text-white hover:text-black font-bold text-sm rounded-xl transition-colors flex items-center justify-center gap-2"
        >
          Get My Quote
          <ArrowRight className="w-4 h-4" />
        </button>

        <p className="text-center text-[0.7rem] text-gray-400">No credit card needed · Instant results</p>
      </div>
    </form>
  )
}
