import { useForm, usePage } from '@inertiajs/react'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { DashboardPageProps } from '@/types'

type RefundNewProps = {
  policy: {
    id: string
    price_amount: number
    price_currency: string
  }
}

function formatPrice(amount: number, currency: string) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency,
  }).format(amount)
}

export default function RefundNew({ policy }: RefundNewProps) {
  const { auth } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug

  const { data, setData, post, processing, errors } = useForm({
    reason: '',
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post(`/${accountSlug}/insurance_policies/${policy.id}/refund`)
  }

  return (
    <DashboardLayout
      title="Initiate Refund"
      breadcrumbs={[
        { label: auth.account?.name || 'Workspace', href: `/${accountSlug}/dashboard` },
        { label: 'Policies', href: `/${accountSlug}/insurance_policies` },
        { label: 'Policy Details', href: `/${accountSlug}/insurance_policies/${policy.id}` },
        { label: 'Refund' },
      ]}
    >
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Initiate Refund</h1>
          <p className="text-muted-foreground mt-1">
            Process a refund for this insurance policy
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Refund Details</CardTitle>
            <CardDescription>
              Refund amount: {formatPrice(policy.price_amount, policy.price_currency)}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="reason">Reason for Refund</Label>
                <Textarea
                  id="reason"
                  placeholder="Provide a reason for the refund..."
                  value={data.reason}
                  onChange={(e) => setData('reason', e.target.value)}
                  rows={4}
                  required
                />
                {errors.reason && (
                  <p className="text-sm text-destructive">{errors.reason}</p>
                )}
              </div>

              <div className="flex items-center gap-2">
                <Button type="submit" disabled={processing}>
                  {processing ? 'Processing...' : 'Submit Refund'}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => {
                    window.location.href = `/${accountSlug}/insurance_policies/${policy.id}`
                  }}
                >
                  Cancel
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
