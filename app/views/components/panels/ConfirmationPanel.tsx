import { useState, useEffect, useRef } from 'react'
import { CheckCircle2, LogIn, Download, Loader2, Mail } from 'lucide-react'

type ConfirmationPanelProps = {
  policyId?: string
  sessionId?: string
  onLogin?: () => void
}

type PdfState = 'checking' | 'ready' | 'timeout'

export function ConfirmationPanel({ policyId, sessionId, onLogin }: ConfirmationPanelProps) {
  const [pdfState, setPdfState] = useState<PdfState>('checking')
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const startTimeRef = useRef<number>(Date.now())

  useEffect(() => {
    if (!policyId) {
      setPdfState('timeout')
      return
    }

    startTimeRef.current = Date.now()

    const checkPdf = async () => {
      try {
        const elapsed = Date.now() - startTimeRef.current
        if (elapsed > 60_000) {
          setPdfState('timeout')
          if (intervalRef.current) clearInterval(intervalRef.current)
          return
        }

        const res = await fetch(`/api/insurance/pdf_download/${policyId}`)
        if (res.ok && res.headers.get('content-type')?.includes('application/pdf')) {
          setPdfState('ready')
          if (intervalRef.current) clearInterval(intervalRef.current)
        }
      } catch {
        // Keep polling on network errors
      }
    }

    checkPdf()
    intervalRef.current = setInterval(checkPdf, 3000)

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
    }
  }, [policyId])

  const handleDownload = () => {
    if (policyId) {
      window.open(`/api/insurance/pdf_download/${policyId}`, '_blank')
    }
  }

  return (
    <div className="space-y-6 py-4">
      <div className="text-center space-y-4">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-yellow-400/20">
          <CheckCircle2 className="h-8 w-8 text-yellow-600" />
        </div>

        <div>
          <h2 className="text-xl font-black text-black tracking-tight">
            You're Covered!
          </h2>
          <p className="text-sm text-gray-500 mt-2">
            Your travel insurance policy has been created.
          </p>
        </div>
      </div>

      <div className="h-px bg-gray-200" />

      {policyId && (
        <div className="text-center space-y-1">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Policy ID</p>
          <p className="text-base font-mono font-bold text-black">{policyId}</p>
        </div>
      )}

      {sessionId && (
        <div className="text-center space-y-1">
          <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-gray-400">Session</p>
          <p className="text-xs font-mono text-gray-500 break-all">{sessionId}</p>
        </div>
      )}

      <div className="h-px bg-gray-200" />

      {/* PDF Download Section */}
      {pdfState === 'checking' && (
        <div className="flex items-center justify-center gap-2 py-3 rounded-xl bg-gray-50 text-sm text-gray-500">
          <Loader2 className="w-4 h-4 animate-spin" />
          Preparing your policy document...
        </div>
      )}

      {pdfState === 'ready' && (
        <button
          onClick={handleDownload}
          className="w-full h-11 rounded-xl bg-black text-white text-sm font-bold hover:bg-yellow-400 hover:text-black transition-colors flex items-center justify-center gap-2"
        >
          <Download className="w-4 h-4" />
          Download Policy PDF
        </button>
      )}

      {pdfState === 'timeout' && (
        <div className="flex items-center justify-center gap-2 py-3 rounded-xl bg-gray-50 text-sm text-gray-500">
          <Mail className="w-4 h-4" />
          Your policy PDF will be emailed to you shortly.
        </div>
      )}

      <p className="text-center text-sm text-gray-500">
        You'll receive a confirmation email shortly with your full policy details and documentation.
      </p>

      {onLogin && (
        <button
          onClick={onLogin}
          className="w-full h-11 rounded-xl border-2 border-gray-200 text-sm font-bold text-gray-600 hover:border-black hover:text-black transition-colors flex items-center justify-center gap-2"
        >
          <LogIn className="w-4 h-4" />
          Sign In to Your Account
        </button>
      )}
    </div>
  )
}
