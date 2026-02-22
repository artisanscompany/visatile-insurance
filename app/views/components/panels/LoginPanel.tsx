import { useState, useEffect } from 'react'
import { KeyRound, Loader2, ArrowLeft, Mail } from 'lucide-react'
import { apiPost } from '@/lib/api'

type LoginPanelProps = {
  initialCode?: string
}

type LoginStep = 'email' | 'verify'

type SessionResponse = {
  status: string
  email: string
  magic_link_code?: string
  redirect_to?: string
}

type VerifyResponse = {
  status: string
  redirect_to: string
  user: { email: string }
}

export function LoginPanel({ initialCode }: LoginPanelProps) {
  const [step, setStep] = useState<LoginStep>(initialCode ? 'verify' : 'email')
  const [email, setEmail] = useState('')
  const [code, setCode] = useState(initialCode || '')
  const [devCode, setDevCode] = useState<string | null>(null)
  const [processing, setProcessing] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Auto-submit if opened with a code (magic link return)
  useEffect(() => {
    if (initialCode && step === 'verify') {
      handleVerify(initialCode)
    }
  }, [])

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setProcessing(true)
    setError(null)

    try {
      const result = await apiPost<SessionResponse>('/api/session', { email_address: email })

      if (result.status === 'not_found') {
        // No account — redirect to registration
        window.location.href = result.redirect_to || '/registration/new'
        return
      }

      if (result.magic_link_code) {
        setDevCode(result.magic_link_code)
      }

      setStep('verify')
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Something went wrong')
    } finally {
      setProcessing(false)
    }
  }

  const handleVerify = async (verifyCode?: string) => {
    const codeToUse = verifyCode || code
    if (!codeToUse) return

    setProcessing(true)
    setError(null)

    try {
      const result = await apiPost<VerifyResponse>('/api/session/magic_link', { code: codeToUse })

      if (result.status === 'authenticated') {
        window.location.href = result.redirect_to || '/'
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Verification failed')
      setProcessing(false)
    }
  }

  const handleVerifySubmit = (e: React.FormEvent) => {
    e.preventDefault()
    handleVerify()
  }

  if (step === 'verify') {
    return (
      <div className="space-y-5 py-4">
        <div className="text-center space-y-3">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-yellow-400/20">
            <Mail className="w-7 h-7 text-yellow-600" />
          </div>
          <div>
            <h2 className="text-xl font-black text-black tracking-tight">Check Your Email</h2>
            <p className="text-sm text-gray-500 mt-1">
              We sent a sign-in code to <strong className="text-black">{email}</strong>
            </p>
          </div>
        </div>

        {devCode && (
          <div className="rounded-xl bg-yellow-50 border border-yellow-200 p-3 text-center">
            <p className="text-[0.65rem] font-bold uppercase tracking-[0.15em] text-yellow-700 mb-1">Dev Mode Code</p>
            <p className="text-lg font-mono font-black text-yellow-800">{devCode}</p>
          </div>
        )}

        {error && (
          <div className="rounded-xl bg-red-50 border border-red-200 p-3 text-sm text-red-700">
            {error}
          </div>
        )}

        <form onSubmit={handleVerifySubmit} className="space-y-4">
          <div className="space-y-1.5">
            <label htmlFor="panel_code" className="text-xs font-semibold text-gray-600">
              Verification Code
            </label>
            <input
              id="panel_code"
              type="text"
              placeholder="Enter code"
              value={code}
              onChange={e => setCode(e.target.value)}
              autoFocus
              required
              className="w-full h-11 px-3 border border-gray-200 rounded-xl text-sm text-center font-mono tracking-widest focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
            />
          </div>

          <button
            type="submit"
            disabled={processing}
            className="w-full h-11 rounded-xl bg-black text-white text-sm font-bold hover:bg-yellow-400 hover:text-black transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {processing ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Verifying...
              </>
            ) : (
              'Verify & Sign In'
            )}
          </button>
        </form>

        <button
          onClick={() => { setStep('email'); setError(null); setDevCode(null) }}
          className="w-full flex items-center justify-center gap-2 text-xs text-gray-500 hover:text-black transition-colors"
        >
          <ArrowLeft className="w-3.5 h-3.5" /> Use a different email
        </button>
      </div>
    )
  }

  // Email step
  return (
    <div className="space-y-5 py-4">
      <div className="text-center space-y-3">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-yellow-400/20">
          <KeyRound className="w-7 h-7 text-yellow-600" />
        </div>
        <div>
          <h2 className="text-xl font-black text-black tracking-tight">Welcome Back</h2>
          <p className="text-sm text-gray-500 mt-1">Sign in with a magic code — no password needed.</p>
        </div>
      </div>

      {error && (
        <div className="rounded-xl bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <form onSubmit={handleEmailSubmit} className="space-y-4">
        <div className="space-y-1.5">
          <label htmlFor="panel_login_email" className="text-xs font-semibold text-gray-600">
            Email Address
          </label>
          <input
            id="panel_login_email"
            type="email"
            placeholder="you@example.com"
            value={email}
            onChange={e => setEmail(e.target.value)}
            autoComplete="email"
            autoFocus
            required
            className="w-full h-11 px-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>

        <button
          type="submit"
          disabled={processing}
          className="w-full h-11 rounded-xl bg-black text-white text-sm font-bold hover:bg-yellow-400 hover:text-black transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
        >
          {processing ? (
            <>
              <Loader2 className="w-4 h-4 animate-spin" />
              Sending code...
            </>
          ) : (
            'Continue with Email'
          )}
        </button>
      </form>

      <p className="text-center text-xs text-gray-400">
        Don't have an account?{' '}
        <a href="/registration/new" className="text-black font-semibold hover:underline">
          Create one
        </a>
      </p>
    </div>
  )
}
