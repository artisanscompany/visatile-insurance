import { Check } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { FlowStep } from '@/contexts/InsuranceFlowContext'

const STEPS: { key: FlowStep; label: string }[] = [
  { key: 'quote', label: 'Quote' },
  { key: 'quote_review', label: 'Review' },
  { key: 'travelers', label: 'Travelers' },
  { key: 'checkout', label: 'Payment' },
  { key: 'confirmation', label: 'Done' },
]

export function PanelStepIndicator({ currentStep }: { currentStep: FlowStep }) {
  const currentIndex = STEPS.findIndex(s => s.key === currentStep)

  return (
    <div className="flex items-center justify-between">
      {STEPS.map((step, index) => {
        const isCompleted = index < currentIndex
        const isCurrent = index === currentIndex

        return (
          <div key={step.key} className="flex items-center flex-1 last:flex-none">
            <div className="flex flex-col items-center">
              <div
                className={cn(
                  'flex h-7 w-7 items-center justify-center rounded-full text-[0.65rem] font-bold transition-colors',
                  isCompleted
                    ? 'bg-yellow-400 text-black'
                    : isCurrent
                      ? 'bg-black text-white'
                      : 'bg-gray-200 text-gray-400'
                )}
              >
                {isCompleted ? (
                  <Check className="h-3.5 w-3.5" />
                ) : (
                  index + 1
                )}
              </div>
              <span
                className={cn(
                  'mt-1.5 text-[0.6rem] font-semibold uppercase tracking-wider',
                  isCompleted || isCurrent ? 'text-black' : 'text-gray-400'
                )}
              >
                {step.label}
              </span>
            </div>

            {index < STEPS.length - 1 && (
              <div
                className={cn(
                  'mx-2 h-0.5 flex-1 rounded-full transition-colors',
                  isCompleted ? 'bg-yellow-400' : 'bg-gray-200'
                )}
              />
            )}
          </div>
        )
      })}
    </div>
  )
}
