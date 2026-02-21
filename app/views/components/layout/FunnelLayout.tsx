import { ReactNode } from 'react'
import { Head, usePage } from '@inertiajs/react'
import { Toaster } from '@/components/ui/sonner'
import { StepIndicator } from '@/pages/Insurance/components/StepIndicator'
import { PageProps } from '@/types'

interface FunnelLayoutProps {
  children: ReactNode
  title?: string
  currentStep: number
}

export function FunnelLayout({ children, title, currentStep }: FunnelLayoutProps) {
  const { flash } = usePage<PageProps>().props

  return (
    <>
      <Head title={title || 'TravelShield'} />

      <div className="min-h-screen bg-background">
        <header className="border-b bg-card">
          <div className="mx-auto max-w-2xl px-4 py-4">
            <a
              href="/"
              className="text-lg font-semibold tracking-tight text-foreground hover:text-foreground/80 transition-colors"
            >
              TravelShield
            </a>
          </div>
        </header>

        <main className="mx-auto max-w-2xl px-4 py-8">
          <div className="mb-8">
            <StepIndicator currentStep={currentStep} />
          </div>

          {(flash.notice || flash.alert) && (
            <div className="mb-6">
              {flash.notice && (
                <div className="rounded-md bg-primary/10 border border-primary/20 p-3 text-sm text-primary">
                  {flash.notice}
                </div>
              )}
              {flash.alert && (
                <div className="rounded-md bg-destructive/10 border border-destructive/20 p-3 text-sm text-destructive">
                  {flash.alert}
                </div>
              )}
            </div>
          )}

          {children}
        </main>
      </div>

      <Toaster />
    </>
  )
}
