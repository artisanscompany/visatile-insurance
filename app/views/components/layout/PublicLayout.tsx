import { ReactNode } from 'react'
import { Head, usePage } from '@inertiajs/react'
import { Toaster } from '@/components/ui/sonner'
import { PageProps } from '@/types'

interface PublicLayoutProps {
  children: ReactNode
  title?: string
  fullWidth?: boolean
}

export function PublicLayout({ children, title, fullWidth = false }: PublicLayoutProps) {
  const { flash } = usePage<PageProps>().props

  return (
    <>
      <Head title={title || 'Assetmaker'} />

      <main className={fullWidth ? '' : 'container mx-auto mt-28 px-5'}>
        {(flash.notice || flash.alert) && (
          <div className="mb-5">
            {flash.notice && (
              <p className="py-2 px-3 bg-green-50 text-green-600 font-medium rounded-md inline-block">
                {flash.notice}
              </p>
            )}
            {flash.alert && (
              <p className="py-2 px-3 bg-destructive/10 text-destructive font-medium rounded-md inline-block">
                {flash.alert}
              </p>
            )}
          </div>
        )}
        {children}
      </main>

      <Toaster />
    </>
  )
}
