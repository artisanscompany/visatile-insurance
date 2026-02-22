import { useForm } from '@inertiajs/react'
import { Loader2, Plus, Trash2, Plane } from 'lucide-react'
import { cn } from '@/lib/utils'
import { FunnelLayout } from '@/components/layout/FunnelLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { SearchableSelect, type SearchableSelectOption } from '@/components/ui/searchable-select'
import { COUNTRIES } from '@/data/countries'
import { LOCALITY_COVERAGES } from '@/data/localities'
import { TRAVEL_TYPES } from '@/data/travel-types'
import { COVERAGE_TIERS } from '@/data/coverage'
import { useMemo } from 'react'

type QuoteNewProps = {
  coverage_tiers: Record<number, string>
  prefill?: {
    start_date: string
    end_date: string
    destination: string
  }
}

type QuoteFormData = {
  start_date: string
  end_date: string
  departure_country: string
  destination_countries: string
  coverage_tier: number
  traveler_birth_dates: string[]
  locality_coverage: number
  type_of_travel: number
}

export default function QuoteNew({ coverage_tiers, prefill }: QuoteNewProps) {
  const { data, setData, post, processing, errors } = useForm<QuoteFormData>({
    start_date: prefill?.start_date || '',
    end_date: prefill?.end_date || '',
    departure_country: '',
    destination_countries: prefill?.destination || '',
    coverage_tier: 1,
    traveler_birth_dates: [''],
    locality_coverage: 207,
    type_of_travel: 1,
  })

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
    post('/insurance/quote')
  }

  const addTraveler = () => {
    setData('traveler_birth_dates', [...data.traveler_birth_dates, ''])
  }

  const removeTraveler = (index: number) => {
    const updated = data.traveler_birth_dates.filter((_, i) => i !== index)
    setData('traveler_birth_dates', updated)
  }

  const updateTravelerBirthDate = (index: number, value: string) => {
    const updated = [...data.traveler_birth_dates]
    updated[index] = value
    setData('traveler_birth_dates', updated)
  }

  return (
    <FunnelLayout title="Get a Quote" currentStep={1}>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Get a Travel Insurance Quote</h1>
          <p className="text-muted-foreground mt-1">
            Enter your trip details to receive an instant quote.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Trip Details</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="start_date">Start Date</Label>
                  <Input
                    id="start_date"
                    type="date"
                    value={data.start_date}
                    onChange={e => setData('start_date', e.target.value)}
                    required
                  />
                  {errors.start_date && (
                    <p className="text-sm text-destructive">{errors.start_date}</p>
                  )}
                </div>

                <div className="space-y-2">
                  <Label htmlFor="end_date">End Date</Label>
                  <Input
                    id="end_date"
                    type="date"
                    value={data.end_date}
                    onChange={e => setData('end_date', e.target.value)}
                    required
                  />
                  {errors.end_date && (
                    <p className="text-sm text-destructive">{errors.end_date}</p>
                  )}
                </div>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label>Departure Country</Label>
                  <SearchableSelect
                    value={data.departure_country}
                    onValueChange={v => setData('departure_country', v)}
                    options={countryOptions}
                    placeholder="Select country..."
                    searchPlaceholder="Search countries..."
                  />
                  {errors.departure_country && (
                    <p className="text-sm text-destructive">{errors.departure_country}</p>
                  )}
                </div>

                <div className="space-y-2">
                  <Label>Destination / Coverage Region</Label>
                  <SearchableSelect
                    value={String(data.locality_coverage)}
                    onValueChange={v => setData('locality_coverage', Number(v))}
                    options={localityOptions}
                    placeholder="Select destination..."
                    searchPlaceholder="Search destinations..."
                  />
                  {errors.destination_countries && (
                    <p className="text-sm text-destructive">{errors.destination_countries}</p>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Plane className="h-5 w-5" />
                Travel Type
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-3 sm:grid-cols-4">
                {TRAVEL_TYPES.map(tt => {
                  const isSelected = data.type_of_travel === tt.id
                  return (
                    <button
                      key={tt.id}
                      type="button"
                      onClick={() => setData('type_of_travel', tt.id)}
                      className={cn(
                        'relative rounded-lg border-2 p-3 text-left transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                        isSelected
                          ? 'border-primary bg-primary/5'
                          : 'border-border hover:border-muted-foreground/50'
                      )}
                    >
                      <div className="font-semibold text-sm">{tt.label}</div>
                      <div className="mt-0.5 text-xs text-muted-foreground">{tt.description}</div>
                      {isSelected && (
                        <div className="absolute right-2 top-2 h-2.5 w-2.5 rounded-full bg-primary" />
                      )}
                    </button>
                  )
                })}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Coverage Tier</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-3 sm:grid-cols-4">
                {COVERAGE_TIERS.map(tier => {
                  const isSelected = data.coverage_tier === tier.id
                  const tierLabel = coverage_tiers[tier.id] || tier.label

                  return (
                    <button
                      key={tier.id}
                      type="button"
                      onClick={() => setData('coverage_tier', tier.id)}
                      className={cn(
                        'relative rounded-lg border-2 p-4 text-left transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                        isSelected
                          ? 'border-primary bg-primary/5'
                          : 'border-border hover:border-muted-foreground/50'
                      )}
                    >
                      <div className="font-semibold">{tierLabel}</div>
                      <div className="mt-1 text-sm text-muted-foreground">
                        Up to {tier.limit}
                      </div>
                      {isSelected && (
                        <div className="absolute right-3 top-3 h-2.5 w-2.5 rounded-full bg-primary" />
                      )}
                    </button>
                  )
                })}
              </div>
              {errors.coverage_tier && (
                <p className="mt-2 text-sm text-destructive">{errors.coverage_tier}</p>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Travelers</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {data.traveler_birth_dates.map((birthDate, index) => (
                <div key={index} className="flex items-end gap-3">
                  <div className="flex-1 space-y-2">
                    <Label htmlFor={`traveler_birth_date_${index}`}>
                      Traveler {index + 1} - Date of Birth
                    </Label>
                    <Input
                      id={`traveler_birth_date_${index}`}
                      type="date"
                      value={birthDate}
                      onChange={e => updateTravelerBirthDate(index, e.target.value)}
                      required
                    />
                    {errors[`traveler_birth_dates.${index}` as keyof typeof errors] && (
                      <p className="text-sm text-destructive">
                        {errors[`traveler_birth_dates.${index}` as keyof typeof errors]}
                      </p>
                    )}
                  </div>
                  {data.traveler_birth_dates.length > 1 && (
                    <Button
                      type="button"
                      variant="outline"
                      size="icon"
                      onClick={() => removeTraveler(index)}
                      className="shrink-0"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              ))}

              {errors.traveler_birth_dates && (
                <p className="text-sm text-destructive">{errors.traveler_birth_dates}</p>
              )}

              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={addTraveler}
                className="mt-2"
              >
                <Plus className="mr-2 h-4 w-4" />
                Add Traveler
              </Button>
            </CardContent>
          </Card>

          <Button type="submit" className="w-full h-11 text-base font-medium" disabled={processing}>
            {processing ? (
              <span className="flex items-center gap-2">
                <Loader2 className="animate-spin h-4 w-4" />
                Getting quote...
              </span>
            ) : (
              'Get Quote'
            )}
          </Button>
        </form>
      </div>
    </FunnelLayout>
  )
}
