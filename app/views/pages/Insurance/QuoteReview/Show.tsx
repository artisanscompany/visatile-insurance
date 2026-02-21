import { router } from '@inertiajs/react'
import { ArrowLeft, ArrowRight } from 'lucide-react'
import { FunnelLayout } from '@/components/layout/FunnelLayout'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'
import type { QuoteRequest, QuoteResponse } from '@/types'

const COVERAGE_LABELS: Record<number, string> = {
  1: 'Standard',
  2: 'Advanced',
  3: 'Premium',
}

type QuoteReviewShowProps = {
  quote_request: QuoteRequest
  quote_response: QuoteResponse
}

export default function QuoteReviewShow({ quote_request, quote_response }: QuoteReviewShowProps) {
  const formatDate = (dateStr: string) => {
    return new Date(dateStr + 'T00:00:00').toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }

  const coverageLabel = COVERAGE_LABELS[quote_response.coverage_tier] || 'Unknown'

  return (
    <FunnelLayout title="Review Quote" currentStep={1}>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Your Quote</h1>
          <p className="text-muted-foreground mt-1">
            Review your travel insurance quote details below.
          </p>
        </div>

        <Card>
          <CardContent className="pt-6">
            <div className="text-center mb-6">
              <p className="text-sm text-muted-foreground mb-1">Total Price</p>
              <p className="text-4xl font-bold tracking-tight">
                {quote_response.price_currency} {quote_response.price_amount}
              </p>
              <Badge variant="secondary" className="mt-2">
                {coverageLabel} Coverage
              </Badge>
            </div>

            <Separator className="my-6" />

            <div className="space-y-4">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Tariff</span>
                <span className="font-medium">{quote_response.tariff_name}</span>
              </div>

              <div className="flex justify-between">
                <span className="text-muted-foreground">Travel Dates</span>
                <span className="font-medium">
                  {formatDate(quote_response.start_date)} &ndash; {formatDate(quote_response.end_date)}
                </span>
              </div>

              <div className="flex justify-between">
                <span className="text-muted-foreground">Departure Country</span>
                <span className="font-medium">{quote_request.departure_country}</span>
              </div>

              <div className="flex justify-between">
                <span className="text-muted-foreground">Destination Countries</span>
                <span className="font-medium">{quote_request.destination_countries.join(', ')}</span>
              </div>

              <div className="flex justify-between">
                <span className="text-muted-foreground">Coverage Tier</span>
                <span className="font-medium">{coverageLabel}</span>
              </div>

              <div className="flex justify-between">
                <span className="text-muted-foreground">Travelers</span>
                <span className="font-medium">
                  {quote_response.traveler_count} {quote_response.traveler_count === 1 ? 'person' : 'people'}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        <div className="flex gap-3">
          <Button
            variant="outline"
            className="flex-1 h-11"
            onClick={() => router.visit('/insurance/quote/new')}
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Button>
          <Button
            className="flex-1 h-11 text-base font-medium"
            onClick={() => router.visit('/insurance/traveler_detail/new')}
          >
            Continue
            <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        </div>
      </div>
    </FunnelLayout>
  )
}
