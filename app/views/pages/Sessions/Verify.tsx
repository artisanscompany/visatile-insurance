import { useState, useRef, useEffect, useCallback } from 'react'
import { router, usePage } from '@inertiajs/react'
import { Mail, Loader2 } from 'lucide-react'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { PageProps } from '@/types'

type VerifyProps = {
  email?: string
}

export default function SessionsVerify({ email }: VerifyProps) {
  const { flash } = usePage<PageProps>().props
  const [digits, setDigits] = useState<string[]>(['', '', '', '', '', ''])
  const [processing, setProcessing] = useState(false)
  const [shake, setShake] = useState(false)
  const [lastShakeId, setLastShakeId] = useState<number | null>(null)
  const inputRefs = useRef<(HTMLInputElement | null)[]>([])
  const submittedCodeRef = useRef<string | null>(null)

  // Handle error flash - clear inputs when shake timestamp changes
  useEffect(() => {
    const shakeId = typeof flash.shake === 'number' ? flash.shake : null

    if (shakeId && shakeId !== lastShakeId) {
      setLastShakeId(shakeId)
      setShake(true)
      setDigits(['', '', '', '', '', ''])
      submittedCodeRef.current = null

      // Focus first input after state update
      requestAnimationFrame(() => {
        inputRefs.current[0]?.focus()
      })

      setTimeout(() => setShake(false), 400)
    }
  }, [flash.shake, lastShakeId])

  // Submit the code
  const submitCode = useCallback((code: string) => {
    if (processing || submittedCodeRef.current === code) return

    submittedCodeRef.current = code
    setProcessing(true)

    router.post('/session/magic_link', { code }, {
      onFinish: () => setProcessing(false),
      onError: () => { submittedCodeRef.current = null }
    })
  }, [processing])

  // Auto-submit when all digits are entered
  useEffect(() => {
    const code = digits.join('')
    if (code.length === 6 && digits.every(d => d !== '') && !shake && !processing) {
      submitCode(code)
    }
  }, [digits, submitCode, shake, processing])

  const handleChange = (index: number, value: string) => {
    // Only allow digits
    const digit = value.replace(/\D/g, '').slice(-1)

    const newDigits = [...digits]
    newDigits[index] = digit
    setDigits(newDigits)

    // Auto-focus next input
    if (digit && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
  }

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !digits[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault()
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (pasted.length > 0) {
      const newDigits = [...digits]
      for (let i = 0; i < 6; i++) {
        newDigits[i] = pasted[i] || ''
      }
      setDigits(newDigits)
      inputRefs.current[Math.min(pasted.length, 5)]?.focus()
    }
  }

  return (
    <PublicLayout title="Enter Code">
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
              <Mail className="w-8 h-8 text-primary" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">Check your email</h1>
            <p className="text-muted-foreground mt-1">
              We sent a code to <span className="font-medium text-foreground">{email}</span>
            </p>
          </div>

          <Card className="border-0 shadow-xl">
            <CardHeader className="space-y-1 pb-2">
              <CardTitle className="text-lg font-semibold text-center">Enter verification code</CardTitle>
              <CardDescription className="text-center">
                Enter the 6-digit code from your email
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                <div
                  className={`flex justify-center gap-2 sm:gap-3 ${shake ? 'animate-shake' : ''}`}
                  onPaste={handlePaste}
                  role="group"
                  aria-label="Verification code input"
                >
                  {digits.map((digit, index) => (
                    <Input
                      key={index}
                      ref={el => { inputRefs.current[index] = el }}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={digit}
                      onChange={e => handleChange(index, e.target.value)}
                      onKeyDown={e => handleKeyDown(index, e)}
                      className="w-11 h-14 sm:w-12 sm:h-16 text-center text-2xl font-bold rounded-lg border-2 focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                      autoFocus={index === 0}
                      disabled={processing}
                      aria-label={`Digit ${index + 1} of 6`}
                    />
                  ))}
                </div>

                {flash.magic_link_code && (
                  <div className="p-4 bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800 rounded-lg text-center">
                    <p className="text-xs text-amber-600 dark:text-amber-400 font-medium uppercase tracking-wide mb-1">Development Mode</p>
                    <p className="text-3xl font-mono font-bold tracking-[0.3em] text-amber-700 dark:text-amber-300">{flash.magic_link_code}</p>
                  </div>
                )}

                {processing && (
                  <div className="flex items-center justify-center gap-2 text-muted-foreground">
                    <Loader2 className="animate-spin h-4 w-4" />
                    <span>Verifying...</span>
                  </div>
                )}

                <div className="text-center pt-2">
                  <p className="text-sm text-muted-foreground mb-2">
                    Didn't receive the code?
                  </p>
                  <Button variant="ghost" size="sm" asChild>
                    <a href="/session/new" className="text-primary">
                      Try a different email
                    </a>
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      <style>{`
        @keyframes shake {
          0%, 100% { transform: translateX(0); }
          20%, 60% { transform: translateX(-6px); }
          40%, 80% { transform: translateX(6px); }
        }
        .animate-shake {
          animation: shake 0.4s ease-in-out;
        }
      `}</style>
    </PublicLayout>
  )
}
