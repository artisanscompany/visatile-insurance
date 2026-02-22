import { createContext, useContext, useState, useCallback, useEffect, type ReactNode } from 'react'

export type PanelType = 'quote' | 'login' | 'confirmation' | 'verify' | null

type PanelContextValue = {
  activePanel: PanelType
  panelParams: Record<string, string>
  openPanel: (panel: PanelType, params?: Record<string, string>) => void
  closePanel: () => void
}

const PanelContext = createContext<PanelContextValue | null>(null)

type PanelProviderProps = {
  children: ReactNode
  initialPanel?: string | null
  initialParams?: Record<string, string>
}

export function PanelProvider({ children, initialPanel, initialParams }: PanelProviderProps) {
  const [activePanel, setActivePanel] = useState<PanelType>(() => {
    return (initialPanel as PanelType) || null
  })
  const [panelParams, setPanelParams] = useState<Record<string, string>>(initialParams || {})

  const openPanel = useCallback((panel: PanelType, params?: Record<string, string>) => {
    setActivePanel(panel)
    setPanelParams(params || {})

    const url = new URL(window.location.href)
    if (panel) {
      url.searchParams.set('panel', panel)
      if (params) {
        Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v))
      }
    } else {
      url.searchParams.delete('panel')
    }
    window.history.pushState({ panel, params }, '', url.toString())
  }, [])

  const closePanel = useCallback(() => {
    setActivePanel(null)
    setPanelParams({})

    const url = new URL(window.location.href)
    url.search = ''
    window.history.pushState({}, '', url.toString())
  }, [])

  // Handle browser back/forward
  useEffect(() => {
    const handler = (e: PopStateEvent) => {
      if (e.state?.panel) {
        setActivePanel(e.state.panel as PanelType)
        setPanelParams(e.state.params || {})
      } else {
        setActivePanel(null)
        setPanelParams({})
      }
    }
    window.addEventListener('popstate', handler)
    return () => window.removeEventListener('popstate', handler)
  }, [])

  return (
    <PanelContext.Provider value={{ activePanel, panelParams, openPanel, closePanel }}>
      {children}
    </PanelContext.Provider>
  )
}

export function usePanel() {
  const context = useContext(PanelContext)
  if (!context) {
    throw new Error('usePanel must be used within a PanelProvider')
  }
  return context
}
