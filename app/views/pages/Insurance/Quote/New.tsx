import { useForm } from '@inertiajs/react'
import { Loader2, Plus, Trash2 } from 'lucide-react'
import { FunnelLayout } from '@/components/layout/FunnelLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

type CoverageTierOption = {
  id: number
  label: string
  limit: string
}

const COVERAGE_TIERS: CoverageTierOption[] = [
  { id: 1, label: 'Standard', limit: '$35,000' },
  { id: 2, label: 'Advanced', limit: '$100,000' },
  { id: 3, label: 'Premium', limit: '$500,000' },
]

type QuoteNewProps = {
  coverage_tiers: Record<number, string>
}

type QuoteFormData = {
  start_date: string
  end_date: string
  departure_country: string
  destination_countries: string
  coverage_tier: number
  traveler_birth_dates: string[]
}

export default function QuoteNew({ coverage_tiers }: QuoteNewProps) {
  const { data, setData, post, processing, errors } = useForm<QuoteFormData>({
    start_date: '',
    end_date: '',
    departure_country: '',
    destination_countries: '',
    coverage_tier: 1,
    traveler_birth_dates: [''],
  })

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
                  <Label htmlFor="departure_country">Departure Country</Label>
                  <Input
                    id="departure_country"
                    type="text"
                    placeholder="US"
                    maxLength={2}
                    value={data.departure_country}
                    onChange={e => setData('departure_country', e.target.value.toUpperCase())}
                    required
                  />
                  <p className="text-xs text-muted-foreground">ISO alpha-2 code (e.g. US, GB, DE)</p>
                  {errors.departure_country && (
                    <p className="text-sm text-destructive">{errors.departure_country}</p>
                  )}
                </div>

                <div className="space-y-2">
                  <Label htmlFor="destination_countries">Destination Countries</Label>
                  <Input
                    id="destination_countries"
                    type="text"
                    placeholder="FR, IT, ES"
                    value={data.destination_countries}
                    onChange={e => setData('destination_countries', e.target.value.toUpperCase())}
                    required
                  />
                  <p className="text-xs text-muted-foreground">Comma-separated ISO alpha-2 codes</p>
                  {errors.destination_countries && (
                    <p className="text-sm text-destructive">{errors.destination_countries}</p>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Coverage Tier</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-3 sm:grid-cols-3">
                {COVERAGE_TIERS.map(tier => {
                  const isSelected = data.coverage_tier === tier.id
                  const tierLabel = coverage_tiers[tier.id] || tier.label

                  return (
                    <button
                      key={tier.id}
                      type="button"
                      onClick={() => setData('coverage_tier', tier.id)}
                      className={`relative rounded-lg border-2 p-4 text-left transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                        isSelected
                          ? 'border-primary bg-primary/5'
                          : 'border-border hover:border-muted-foreground/50'
                      }`}
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
