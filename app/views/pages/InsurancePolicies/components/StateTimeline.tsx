import { cn } from '@/lib/utils'
import { PolicyStateEntry } from '@/types'

type StateTimelineProps = {
  entries: PolicyStateEntry[]
}

const stateColors: Record<string, string> = {
  policy_pending_payment: 'bg-yellow-500',
  policy_payment_received: 'bg-blue-500',
  policy_contract_created: 'bg-blue-500',
  policy_contract_confirmed: 'bg-blue-500',
  policy_completed: 'bg-green-500',
  policy_failed: 'bg-red-500',
  policy_refund_initiated: 'bg-orange-500',
  policy_refunded: 'bg-gray-500',
}

function formatStateName(state: string): string {
  return state
    .replace(/^policy_/, '')
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

function formatTimestamp(dateString: string): string {
  return new Date(dateString).toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}

export function StateTimeline({ entries }: StateTimelineProps) {
  if (entries.length === 0) {
    return (
      <p className="text-sm text-muted-foreground">No state history available.</p>
    )
  }

  return (
    <div className="relative space-y-0">
      {entries.map((entry, index) => {
        const dotColor = stateColors[entry.state] || 'bg-gray-400'
        const isLast = index === entries.length - 1
        const detailEntries = Object.entries(entry.details || {})

        return (
          <div key={index} className="relative flex gap-4 pb-6 last:pb-0">
            {/* Vertical line */}
            {!isLast && (
              <div className="absolute left-[7px] top-4 h-full w-px bg-border" />
            )}

            {/* Dot */}
            <div className="relative z-10 mt-1.5 flex shrink-0">
              <div className={cn('h-[15px] w-[15px] rounded-full ring-4 ring-background', dotColor)} />
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium">{formatStateName(entry.state)}</p>
              <p className="text-xs text-muted-foreground mt-0.5">
                {formatTimestamp(entry.created_at)}
              </p>

              {detailEntries.length > 0 && (
                <div className="mt-2 rounded-md bg-muted/50 p-2 text-xs">
                  {detailEntries.map(([key, value]) => (
                    <div key={key} className="flex gap-2">
                      <span className="font-medium text-muted-foreground">
                        {key.replace(/_/g, ' ')}:
                      </span>
                      <span className="text-foreground">{String(value)}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
