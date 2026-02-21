import { usePage } from '@inertiajs/react'
import { FileText } from 'lucide-react'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
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
import { DashboardPageProps, PolicySummary } from '@/types'

type InsurancePoliciesIndexProps = {
  policies: PolicySummary[]
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

export default function InsurancePoliciesIndex({ policies }: InsurancePoliciesIndexProps) {
  const { auth } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug

  return (
    <DashboardLayout title="Policies">
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Insurance Policies</h1>
          <p className="text-muted-foreground mt-1">
            View and manage your travel insurance policies
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>All Policies</CardTitle>
            <CardDescription>
              {policies.length} polic{policies.length !== 1 ? 'ies' : 'y'} in this workspace
            </CardDescription>
          </CardHeader>
          <CardContent>
            {policies.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <div className="h-12 w-12 rounded-full bg-muted flex items-center justify-center mb-4">
                  <FileText className="h-6 w-6 text-muted-foreground" />
                </div>
                <h3 className="font-semibold mb-1">No policies yet</h3>
                <p className="text-sm text-muted-foreground max-w-sm">
                  Insurance policies will appear here once they are created.
                </p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Dates</TableHead>
                    <TableHead>Coverage</TableHead>
                    <TableHead>Price</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Created</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {policies.map((policy) => (
                    <TableRow
                      key={policy.id}
                      className="cursor-pointer"
                      onClick={() => {
                        window.location.href = `/${accountSlug}/insurance_policies/${policy.id}`
                      }}
                    >
                      <TableCell className="font-medium">
                        {formatDate(policy.start_date)} - {formatDate(policy.end_date)}
                      </TableCell>
                      <TableCell>{policy.coverage_label}</TableCell>
                      <TableCell>
                        {formatPrice(policy.price_amount, policy.price_currency)}
                      </TableCell>
                      <TableCell>
                        <PolicyStatusBadge state={policy.current_state} />
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {formatDate(policy.created_at)}
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
