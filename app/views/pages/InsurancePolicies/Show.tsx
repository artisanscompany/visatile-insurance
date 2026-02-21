import { router, usePage } from '@inertiajs/react'
import { Download, RotateCcw, CreditCard } from 'lucide-react'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { PolicyStatusBadge } from './components/PolicyStatusBadge'
import { StateTimeline } from './components/StateTimeline'
import { DashboardPageProps, PolicyDetail, TravelerDetail, PolicyStateEntry } from '@/types'

type InsurancePoliciesShowProps = {
  policy: PolicyDetail
  travelers: TravelerDetail[]
  current_state: string
  state_history: PolicyStateEntry[]
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

function formatPrice(amount: number, currency: string) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency,
  }).format(amount)
}

export default function InsurancePoliciesShow({
  policy,
  travelers,
  current_state,
  state_history,
}: InsurancePoliciesShowProps) {
  const { auth } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug
  const isSuperuser = auth.superuser

  const handleRetry = () => {
    router.post(`/${accountSlug}/insurance_policies/${policy.id}/retry`, {}, {
      preserveScroll: true,
    })
  }

  return (
    <DashboardLayout
      title="Policy Details"
      breadcrumbs={[
        { label: auth.account?.name || 'Workspace', href: `/${accountSlug}/dashboard` },
        { label: 'Policies', href: `/${accountSlug}/insurance_policies` },
        { label: 'Policy Details' },
      ]}
    >
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Policy Details</h1>
            <p className="text-muted-foreground mt-1">
              {formatDate(policy.start_date)} - {formatDate(policy.end_date)}
            </p>
          </div>

          <div className="flex items-center gap-2">
            {current_state === 'policy_completed' && (
              <Button asChild>
                <a href={`/${accountSlug}/insurance_policies/${policy.id}/pdf_download`}>
                  <Download className="mr-2 h-4 w-4" />
                  Download PDF
                </a>
              </Button>
            )}

            {current_state === 'policy_failed' && isSuperuser && (
              <Button variant="outline" onClick={handleRetry}>
                <RotateCcw className="mr-2 h-4 w-4" />
                Retry
              </Button>
            )}

            {current_state === 'policy_payment_received' && isSuperuser && (
              <Button variant="outline" asChild>
                <a href={`/${accountSlug}/insurance_policies/${policy.id}/refund/new`}>
                  <CreditCard className="mr-2 h-4 w-4" />
                  Refund
                </a>
              </Button>
            )}
          </div>
        </div>

        {/* Policy Details Card */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Policy Information</CardTitle>
                <CardDescription>Coverage and pricing details</CardDescription>
              </div>
              <PolicyStatusBadge state={current_state} />
            </div>
          </CardHeader>
          <CardContent>
            <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <div>
                <dt className="text-sm font-medium text-muted-foreground">Travel Dates</dt>
                <dd className="mt-1 text-sm">
                  {formatDate(policy.start_date)} - {formatDate(policy.end_date)}
                </dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-muted-foreground">Departure Country</dt>
                <dd className="mt-1 text-sm">{policy.departure_country}</dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-muted-foreground">Destination Countries</dt>
                <dd className="mt-1 text-sm">{policy.destination_countries.join(', ')}</dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-muted-foreground">Coverage</dt>
                <dd className="mt-1 text-sm">{policy.coverage_label}</dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-muted-foreground">Price</dt>
                <dd className="mt-1 text-sm font-semibold">
                  {formatPrice(policy.price_amount, policy.price_currency)}
                </dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-muted-foreground">Created</dt>
                <dd className="mt-1 text-sm">{formatDate(policy.created_at)}</dd>
              </div>
            </dl>
          </CardContent>
        </Card>

        {/* Travelers Table */}
        <Card>
          <CardHeader>
            <CardTitle>Travelers</CardTitle>
            <CardDescription>
              {travelers.length} traveler{travelers.length !== 1 ? 's' : ''} on this policy
            </CardDescription>
          </CardHeader>
          <CardContent>
            {travelers.length === 0 ? (
              <p className="text-sm text-muted-foreground">No travelers on this policy.</p>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Date of Birth</TableHead>
                    <TableHead>Passport</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {travelers.map((traveler) => (
                    <TableRow key={traveler.id}>
                      <TableCell className="font-medium">
                        {traveler.first_name} {traveler.last_name}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {formatDate(traveler.birth_date)}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {traveler.passport_number} ({traveler.passport_country})
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>

        {/* State Timeline */}
        <Card>
          <CardHeader>
            <CardTitle>State History</CardTitle>
            <CardDescription>Timeline of policy state changes</CardDescription>
          </CardHeader>
          <CardContent>
            <StateTimeline entries={state_history} />
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
