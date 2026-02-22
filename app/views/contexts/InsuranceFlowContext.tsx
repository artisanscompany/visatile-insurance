import { createContext, useContext, useReducer, useCallback, type ReactNode } from 'react'
import { apiPost } from '@/lib/api'

// Types
export type FlowStep = 'quote' | 'quote_review' | 'travelers' | 'checkout' | 'confirmation'

export type QuoteFormData = {
  start_date: string
  end_date: string
  departure_country: string
  destination_countries: string
  coverage_tier: number
  traveler_birth_dates: string[]
  locality_coverage: number
  type_of_travel: number
}

export type QuoteResponse = {
  tariff_id: string
  tariff_name: string
  price_amount: string
  price_currency: string
  coverage_tier: number
  start_date: string
  end_date: string
  traveler_count: number
  locality_coverage: number
}

export type TravelerEntry = {
  first_name: string
  last_name: string
  birth_date: string
  passport_number: string
  passport_country: string
}

type InsuranceFlowState = {
  step: FlowStep
  quoteFormData: QuoteFormData | null
  quoteRequest: Record<string, unknown> | null
  quoteResponse: QuoteResponse | null
  travelers: TravelerEntry[] | null
  email: string | null
  policyId: string | null
  error: string | null
  processing: boolean
}

type Action =
  | { type: 'SET_PROCESSING'; processing: boolean }
  | { type: 'SET_ERROR'; error: string | null }
  | { type: 'QUOTE_SUBMITTED'; quoteFormData: QuoteFormData; quoteRequest: Record<string, unknown>; quoteResponse: QuoteResponse }
  | { type: 'GO_TO_TRAVELERS' }
  | { type: 'TRAVELERS_SAVED'; travelers: TravelerEntry[] }
  | { type: 'CHECKOUT_STARTED'; email: string }
  | { type: 'PURCHASE_COMPLETED'; policyId: string }
  | { type: 'GO_BACK' }
  | { type: 'RESET' }

const STEP_ORDER: FlowStep[] = ['quote', 'quote_review', 'travelers', 'checkout', 'confirmation']

const initialState: InsuranceFlowState = {
  step: 'quote',
  quoteFormData: null,
  quoteRequest: null,
  quoteResponse: null,
  travelers: null,
  email: null,
  policyId: null,
  error: null,
  processing: false,
}

function reducer(state: InsuranceFlowState, action: Action): InsuranceFlowState {
  switch (action.type) {
    case 'SET_PROCESSING':
      return { ...state, processing: action.processing, error: null }
    case 'SET_ERROR':
      return { ...state, error: action.error, processing: false }
    case 'QUOTE_SUBMITTED':
      return {
        ...state,
        step: 'quote_review',
        quoteFormData: action.quoteFormData,
        quoteRequest: action.quoteRequest,
        quoteResponse: action.quoteResponse,
        processing: false,
        error: null,
      }
    case 'GO_TO_TRAVELERS':
      return { ...state, step: 'travelers' }
    case 'TRAVELERS_SAVED':
      return { ...state, step: 'checkout', travelers: action.travelers }
    case 'CHECKOUT_STARTED':
      return { ...state, email: action.email, processing: true }
    case 'PURCHASE_COMPLETED':
      return { ...state, step: 'confirmation', policyId: action.policyId, processing: false }
    case 'GO_BACK': {
      const currentIndex = STEP_ORDER.indexOf(state.step)
      if (currentIndex > 0) {
        return { ...state, step: STEP_ORDER[currentIndex - 1], error: null }
      }
      return state
    }
    case 'RESET':
      return initialState
    default:
      return state
  }
}

// Context
type InsuranceFlowContextValue = {
  state: InsuranceFlowState
  submitQuote: (data: QuoteFormData) => Promise<void>
  goToTravelers: () => void
  saveTravelers: (travelers: TravelerEntry[]) => void
  submitCheckout: (email: string) => Promise<void>
  goBack: () => void
  reset: () => void
}

const InsuranceFlowContext = createContext<InsuranceFlowContextValue | null>(null)

export function InsuranceFlowProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState)

  const submitQuote = useCallback(async (data: QuoteFormData) => {
    dispatch({ type: 'SET_PROCESSING', processing: true })
    try {
      const result = await apiPost<{ quote_request: Record<string, unknown>; quote_response: QuoteResponse }>(
        '/api/insurance/quote',
        { quote: data }
      )
      dispatch({
        type: 'QUOTE_SUBMITTED',
        quoteFormData: data,
        quoteRequest: result.quote_request,
        quoteResponse: result.quote_response,
      })
    } catch (e) {
      dispatch({ type: 'SET_ERROR', error: e instanceof Error ? e.message : 'Failed to get quote' })
    }
  }, [])

  const goToTravelers = useCallback(() => {
    dispatch({ type: 'GO_TO_TRAVELERS' })
  }, [])

  const saveTravelers = useCallback((travelers: TravelerEntry[]) => {
    dispatch({ type: 'TRAVELERS_SAVED', travelers })
  }, [])

  const submitCheckout = useCallback(async (email: string) => {
    dispatch({ type: 'CHECKOUT_STARTED', email })
    try {
      const result = await apiPost<{ stripe_url: string; policy_id: string }>(
        '/api/insurance/checkout',
        {
          email,
          quote_request: state.quoteRequest,
          quote_response: state.quoteResponse,
          travelers: state.travelers,
        }
      )
      // Redirect to Stripe — the user leaves the page
      window.location.href = result.stripe_url
    } catch (e) {
      dispatch({ type: 'SET_ERROR', error: e instanceof Error ? e.message : 'Checkout failed' })
    }
  }, [state.quoteRequest, state.quoteResponse, state.travelers])

  const goBack = useCallback(() => dispatch({ type: 'GO_BACK' }), [])
  const reset = useCallback(() => dispatch({ type: 'RESET' }), [])

  return (
    <InsuranceFlowContext.Provider value={{ state, submitQuote, goToTravelers, saveTravelers, submitCheckout, goBack, reset }}>
      {children}
    </InsuranceFlowContext.Provider>
  )
}

export function useInsuranceFlow() {
  const context = useContext(InsuranceFlowContext)
  if (!context) {
    throw new Error('useInsuranceFlow must be used within InsuranceFlowProvider')
  }
  return context
}
