import { useForm } from '@inertiajs/react'
import { CreditCard, Loader2, Shield } from 'lucide-react'
import { FunnelLayout } from '@/components/layout/FunnelLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'
import type { QuoteRequest, QuoteResponse, TravelerData } from '@/types'
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

type CheckoutNewProps = {
  quote_request: QuoteRequest
  quote_response: QuoteResponse
  travelers: TravelerData[]
}

export default function CheckoutNew({
  quote_request,
  quote_response,
  travelers,
}: CheckoutNewProps) {
  const { data, setData, post, processing, errors } = useForm({
    email: '',
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post('/insurance/checkout')
  }

  const formatDate = (dateStr: string) => {
    return new Date(dateStr + 'T00:00:00').toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }

  const coverageLabel = COVERAGE_LABELS[quote_response.coverage_tier] || 'Unknown'
  const departureDisplay = COUNTRY_MAP[quote_request.departure_country] || quote_request.departure_country
  const localityCoverage = quote_response.locality_coverage || (quote_request as Record<string, unknown>).locality_coverage as number
  const destinationDisplay = localityCoverage ? (LOCALITY_MAP[localityCoverage] || `Region ${localityCoverage}`) : quote_request.destination_countries.join(', ')
  const travelType = (quote_request as Record<string, unknown>).type_of_travel as number | undefined
  const travelTypeDisplay = travelType ? (TRAVEL_TYPE_MAP[travelType] || '') : ''

  return (
    <FunnelLayout title="Checkout" currentStep={3}>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Checkout</h1>
          <p className="text-muted-foreground mt-1">
            Review your order and complete payment.
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Order Summary</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Travel Dates</span>
              <span className="font-medium">
                {formatDate(quote_response.start_date)} &ndash; {formatDate(quote_response.end_date)}
              </span>
            </div>

            <div className="flex justify-between">
              <span className="text-muted-foreground">Departure</span>
              <span className="font-medium">{departureDisplay}</span>
            </div>

            <div className="flex justify-between">
              <span className="text-muted-foreground">Destination</span>
              <span className="font-medium">{destinationDisplay}</span>
            </div>

            {travelTypeDisplay && (
              <div className="flex justify-between">
                <span className="text-muted-foreground">Travel Type</span>
                <span className="font-medium">{travelTypeDisplay}</span>
              </div>
            )}

            <div className="flex justify-between">
              <span className="text-muted-foreground">Coverage</span>
              <Badge variant="secondary">{coverageLabel}</Badge>
            </div>

            <div className="flex justify-between">
              <span className="text-muted-foreground">Travelers</span>
              <span className="font-medium">
                {travelers.length} {travelers.length === 1 ? 'person' : 'people'}
              </span>
            </div>

            <Separator />

            <div className="flex justify-between items-baseline">
              <span className="text-lg font-semibold">Total</span>
              <span className="text-2xl font-bold">
                {quote_response.price_currency} {quote_response.price_amount}
              </span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Contact Information</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="email">Email Address</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={data.email}
                  onChange={e => setData('email', e.target.value)}
                  autoComplete="email"
                  required
                />
                <p className="text-xs text-muted-foreground">
                  We'll send your policy confirmation to this email.
                </p>
                {errors.email && (
                  <p className="text-sm text-destructive">{errors.email}</p>
                )}
              </div>

              <Button type="submit" className="w-full h-11 text-base font-medium" disabled={processing}>
                {processing ? (
                  <span className="flex items-center gap-2">
                    <Loader2 className="animate-spin h-4 w-4" />
                    Processing payment...
                  </span>
                ) : (
                  <span className="flex items-center gap-2">
                    <CreditCard className="h-4 w-4" />
                    Pay with Stripe
                  </span>
                )}
              </Button>

              <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground">
                <Shield className="h-3.5 w-3.5" />
                <span>Secure payment processed by Stripe</span>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </FunnelLayout>
  )
}
