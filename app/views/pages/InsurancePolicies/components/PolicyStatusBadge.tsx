import { Badge } from '@/components/ui/badge'

type PolicyState =
  | 'policy_pending_payment'
  | 'policy_payment_received'
  | 'policy_contract_created'
  | 'policy_contract_confirmed'
  | 'policy_completed'
  | 'policy_failed'
  | 'policy_refund_initiated'
  | 'policy_refunded'

type PolicyStatusBadgeProps = {
  state: string
}

const stateConfig: Record<PolicyState, { label: string; variant: 'default' | 'secondary' | 'destructive' | 'outline'; className?: string }> = {
  policy_pending_payment: {
    label: 'Pending Payment',
    variant: 'outline',
    className: 'border-yellow-500/50 bg-yellow-50 text-yellow-700 dark:bg-yellow-950/30 dark:text-yellow-400',
  },
  policy_payment_received: {
    label: 'Payment Received',
    variant: 'outline',
    className: 'border-blue-500/50 bg-blue-50 text-blue-700 dark:bg-blue-950/30 dark:text-blue-400',
  },
  policy_contract_created: {
    label: 'Contract Created',
    variant: 'outline',
    className: 'border-blue-500/50 bg-blue-50 text-blue-700 dark:bg-blue-950/30 dark:text-blue-400',
  },
  policy_contract_confirmed: {
    label: 'Contract Confirmed',
    variant: 'outline',
    className: 'border-blue-500/50 bg-blue-50 text-blue-700 dark:bg-blue-950/30 dark:text-blue-400',
  },
  policy_completed: {
    label: 'Completed',
    variant: 'outline',
    className: 'border-green-500/50 bg-green-50 text-green-700 dark:bg-green-950/30 dark:text-green-400',
  },
  policy_failed: {
    label: 'Failed',
    variant: 'destructive',
  },
  policy_refund_initiated: {
    label: 'Refund Initiated',
    variant: 'outline',
    className: 'border-orange-500/50 bg-orange-50 text-orange-700 dark:bg-orange-950/30 dark:text-orange-400',
  },
  policy_refunded: {
    label: 'Refunded',
    variant: 'outline',
    className: 'border-gray-500/50 bg-gray-50 text-gray-700 dark:bg-gray-950/30 dark:text-gray-400',
  },
}

export function PolicyStatusBadge({ state }: PolicyStatusBadgeProps) {
  const config = stateConfig[state as PolicyState]

  if (!config) {
    return <Badge variant="outline">{state}</Badge>
  }

  return (
    <Badge variant={config.variant} className={config.className}>
      {config.label}
    </Badge>
  )
}
