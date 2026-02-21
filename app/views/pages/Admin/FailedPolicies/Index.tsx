import { router, usePage } from '@inertiajs/react'
import { RotateCcw } from 'lucide-react'
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
import { DashboardPageProps, FailedPolicySummary } from '@/types'

type FailedPoliciesIndexProps = {
  policies: FailedPolicySummary[]
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

function formatTimestamp(dateString: string) {
  return new Date(dateString).toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}

function formatPrice(amount: number, currency: string) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency,
  }).format(amount)
}

function truncate(text: string, maxLength: number = 60): string {
  if (text.length <= maxLength) return text
  return text.slice(0, maxLength) + '...'
}

export default function FailedPoliciesIndex({ policies }: FailedPoliciesIndexProps) {
  const { auth } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug

  const handleRetry = (policyId: string) => {
    router.post(`/${accountSlug}/insurance_policies/${policyId}/retry`, {}, {
      preserveScroll: true,
    })
  }

  return (
    <DashboardLayout
      title="Failed Policies"
      breadcrumbs={[
        { label: auth.account?.name || 'Workspace', href: `/${accountSlug}/dashboard` },
        { label: 'Failed Policies' },
      ]}
    >
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Failed Policies</h1>
          <p className="text-muted-foreground mt-1">
            Review and retry policies that failed during processing
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Failed Policies</CardTitle>
            <CardDescription>
              {policies.length} failed polic{policies.length !== 1 ? 'ies' : 'y'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {policies.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <h3 className="font-semibold mb-1">No failed policies</h3>
                <p className="text-sm text-muted-foreground">
                  All policies have been processed successfully.
                </p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Dates</TableHead>
                    <TableHead>Price</TableHead>
                    <TableHead>Coverage</TableHead>
                    <TableHead>Failed Step</TableHead>
                    <TableHead>Error Message</TableHead>
                    <TableHead>Failed At</TableHead>
                    <TableHead className="w-[80px]" />
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {policies.map((policy) => (
                    <TableRow key={policy.id}>
                      <TableCell className="font-medium whitespace-nowrap">
                        {formatDate(policy.start_date)} - {formatDate(policy.end_date)}
                      </TableCell>
                      <TableCell>
                        {formatPrice(policy.price_amount, policy.price_currency)}
                      </TableCell>
                      <TableCell>{policy.coverage_label}</TableCell>
                      <TableCell>
                        <code className="rounded bg-muted px-1.5 py-0.5 text-xs">
                          {policy.failed_step}
                        </code>
                      </TableCell>
                      <TableCell
                        className="max-w-[200px] text-muted-foreground"
                        title={policy.error_message}
                      >
                        {truncate(policy.error_message)}
                      </TableCell>
                      <TableCell className="text-muted-foreground whitespace-nowrap">
                        {formatTimestamp(policy.failed_at)}
                      </TableCell>
                      <TableCell>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleRetry(policy.id)}
                        >
                          <RotateCcw className="mr-1 h-3 w-3" />
                          Retry
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
