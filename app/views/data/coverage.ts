export type CoverageTierOption = {
  id: number
  label: string
  limit: string
  amount: number
}

export const COVERAGE_TIERS: CoverageTierOption[] = [
  { id: 1, label: 'Standard', limit: '$35,000', amount: 35000 },
  { id: 2, label: 'Advanced', limit: '$100,000', amount: 100000 },
  { id: 3, label: 'Premium', limit: '$500,000', amount: 500000 },
  { id: 4, label: 'Ultimate', limit: '$1,000,000', amount: 1000000 },
]

export const COVERAGE_LABELS: Record<number, string> = Object.fromEntries(
  COVERAGE_TIERS.map(t => [t.id, t.label])
)
