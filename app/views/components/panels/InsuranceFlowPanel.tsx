import { InsuranceFlowProvider, useInsuranceFlow } from '@/contexts/InsuranceFlowContext'
import { SlidePanel } from '@/components/layout/SlidePanel'
import { PanelStepIndicator } from './PanelStepIndicator'
import { QuoteFormPanel } from './QuoteFormPanel'
import { QuoteReviewPanel } from './QuoteReviewPanel'
import { TravelerDetailsPanel } from './TravelerDetailsPanel'
import { CheckoutPanel } from './CheckoutPanel'
import { ConfirmationPanel } from './ConfirmationPanel'

type InsuranceFlowPanelProps = {
  open: boolean
  onClose: () => void
  prefill?: Record<string, string>
}

function FlowContent({ onClose }: { onClose: () => void }) {
  const { state, reset } = useInsuranceFlow()

  const handleClose = () => {
    reset()
    onClose()
  }

  const stepTitles = {
    quote: 'Get Covered',
    quote_review: 'Your Quote',
    travelers: 'Traveler Details',
    checkout: 'Checkout',
    confirmation: 'Confirmed',
  }

  return (
    <SlidePanel
      open={true}
      onClose={handleClose}
      title={stepTitles[state.step]}
      stepIndicator={<PanelStepIndicator currentStep={state.step} />}
    >
      {state.step === 'quote' && <QuoteFormPanel />}
      {state.step === 'quote_review' && <QuoteReviewPanel />}
      {state.step === 'travelers' && <TravelerDetailsPanel />}
      {state.step === 'checkout' && <CheckoutPanel />}
      {state.step === 'confirmation' && <ConfirmationPanel />}
    </SlidePanel>
  )
}

export function InsuranceFlowPanel({ open, onClose, prefill }: InsuranceFlowPanelProps) {
  if (!open) return null

  return (
    <InsuranceFlowProvider prefill={prefill}>
      <FlowContent onClose={onClose} />
    </InsuranceFlowProvider>
  )
}
