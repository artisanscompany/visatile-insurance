import { useForm } from '@inertiajs/react'
import { Loader2, User } from 'lucide-react'
import { useMemo } from 'react'
import { FunnelLayout } from '@/components/layout/FunnelLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { SearchableSelect } from '@/components/ui/searchable-select'
import { COUNTRIES } from '@/data/countries'
import type { TravelerData } from '@/types'

type TravelerDetailNewProps = {
  traveler_count: number
  traveler_birth_dates: string[]
  saved_travelers: TravelerData[] | null
}

type TravelerFormEntry = {
  first_name: string
  last_name: string
  birth_date: string
  passport_number: string
  passport_country: string
}

export default function TravelerDetailNew({
  traveler_count,
  traveler_birth_dates,
  saved_travelers,
}: TravelerDetailNewProps) {
  const countryOptions = useMemo(
    () => COUNTRIES.map(c => ({ value: c.code, label: `${c.name} (${c.code})` })),
    []
  )
  const initialTravelers: TravelerFormEntry[] = Array.from(
    { length: traveler_count },
    (_, index) => {
      const saved = saved_travelers?.[index]
      return {
        first_name: saved?.first_name || '',
        last_name: saved?.last_name || '',
        birth_date: saved?.birth_date || traveler_birth_dates[index] || '',
        passport_number: saved?.passport_number || '',
        passport_country: saved?.passport_country || '',
      }
    }
  )

  const { data, setData, post, processing, errors } = useForm<{
    travelers: TravelerFormEntry[]
  }>({
    travelers: initialTravelers,
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post('/insurance/traveler_detail')
  }

  const updateTraveler = (
    index: number,
    field: keyof TravelerFormEntry,
    value: string
  ) => {
    const updated = [...data.travelers]
    updated[index] = { ...updated[index], [field]: value }
    setData('travelers', updated)
  }

  const getError = (index: number, field: string): string | undefined => {
    return errors[`travelers.${index}.${field}` as keyof typeof errors]
  }

  return (
    <FunnelLayout title="Traveler Details" currentStep={2}>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Traveler Details</h1>
          <p className="text-muted-foreground mt-1">
            Provide passport and personal information for {traveler_count === 1 ? 'the traveler' : `all ${traveler_count} travelers`}.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {data.travelers.map((traveler, index) => (
            <Card key={index}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <User className="h-5 w-5 text-muted-foreground" />
                  Traveler {index + 1}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor={`travelers_${index}_first_name`}>First Name</Label>
                    <Input
                      id={`travelers_${index}_first_name`}
                      type="text"
                      placeholder="John"
                      value={traveler.first_name}
                      onChange={e => updateTraveler(index, 'first_name', e.target.value)}
                      required
                    />
                    {getError(index, 'first_name') && (
                      <p className="text-sm text-destructive">{getError(index, 'first_name')}</p>
                    )}
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor={`travelers_${index}_last_name`}>Last Name</Label>
                    <Input
                      id={`travelers_${index}_last_name`}
                      type="text"
                      placeholder="Doe"
                      value={traveler.last_name}
                      onChange={e => updateTraveler(index, 'last_name', e.target.value)}
                      required
                    />
                    {getError(index, 'last_name') && (
                      <p className="text-sm text-destructive">{getError(index, 'last_name')}</p>
                    )}
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor={`travelers_${index}_birth_date`}>Date of Birth</Label>
                  <Input
                    id={`travelers_${index}_birth_date`}
                    type="date"
                    value={traveler.birth_date}
                    onChange={e => updateTraveler(index, 'birth_date', e.target.value)}
                    required
                  />
                  {getError(index, 'birth_date') && (
                    <p className="text-sm text-destructive">{getError(index, 'birth_date')}</p>
                  )}
                </div>

                <Separator />

                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor={`travelers_${index}_passport_number`}>Passport Number</Label>
                    <Input
                      id={`travelers_${index}_passport_number`}
                      type="text"
                      placeholder="AB1234567"
                      value={traveler.passport_number}
                      onChange={e => updateTraveler(index, 'passport_number', e.target.value)}
                      required
                    />
                    {getError(index, 'passport_number') && (
                      <p className="text-sm text-destructive">{getError(index, 'passport_number')}</p>
                    )}
                  </div>

                  <div className="space-y-2">
                    <Label>Passport Country</Label>
                    <SearchableSelect
                      value={traveler.passport_country}
                      onValueChange={v => updateTraveler(index, 'passport_country', v)}
                      options={countryOptions}
                      placeholder="Select country..."
                      searchPlaceholder="Search countries..."
                    />
                    {getError(index, 'passport_country') && (
                      <p className="text-sm text-destructive">{getError(index, 'passport_country')}</p>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}

          {errors.travelers && (
            <p className="text-sm text-destructive">{errors.travelers}</p>
          )}

          <Button type="submit" className="w-full h-11 text-base font-medium" disabled={processing}>
            {processing ? (
              <span className="flex items-center gap-2">
                <Loader2 className="animate-spin h-4 w-4" />
                Saving travelers...
              </span>
            ) : (
              'Continue to Payment'
            )}
          </Button>
        </form>
      </div>
    </FunnelLayout>
  )
}
