import { Head, usePage } from '@inertiajs/react'
import { SidebarInset, SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar'
import { Separator } from '@/components/ui/separator'
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '@/components/ui/breadcrumb'
import { AppSidebar } from './AppSidebar'
import { DashboardPageProps } from '@/types'

type BreadcrumbItem = {
  label: string
  href?: string
}

type DashboardLayoutProps = {
  children: React.ReactNode
  title: string
  breadcrumbs?: BreadcrumbItem[]
}

export function DashboardLayout({ children, title, breadcrumbs = [] }: DashboardLayoutProps) {
  const { flash, auth } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug

  // Build default breadcrumbs if none provided
  const defaultBreadcrumbs: BreadcrumbItem[] = [
    { label: auth.account?.name || 'Workspace', href: `/${accountSlug}/dashboard` },
    { label: title },
  ]

  const finalBreadcrumbs = breadcrumbs.length > 0 ? breadcrumbs : defaultBreadcrumbs

  return (
    <>
      <Head title={title} />
      <SidebarProvider>
        <AppSidebar />
        <SidebarInset>
          <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
            <SidebarTrigger className="-ml-1" />
            <Separator orientation="vertical" className="mr-2 h-4" />
            <Breadcrumb>
              <BreadcrumbList>
                {finalBreadcrumbs.map((item, index) => (
                  <BreadcrumbItem key={index}>
                    {index > 0 && <BreadcrumbSeparator />}
                    {item.href ? (
                      <BreadcrumbLink href={item.href}>{item.label}</BreadcrumbLink>
                    ) : (
                      <BreadcrumbPage>{item.label}</BreadcrumbPage>
                    )}
                  </BreadcrumbItem>
                ))}
              </BreadcrumbList>
            </Breadcrumb>
          </header>

          {(flash.notice || flash.alert) && (
            <div className="border-b px-4 py-3">
              {flash.notice && (
                <div className="rounded-md bg-green-50 dark:bg-green-950/30 border border-green-200 dark:border-green-800 p-3 text-sm text-green-700 dark:text-green-300">
                  {flash.notice}
                </div>
              )}
              {flash.alert && (
                <div className="rounded-md bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-800 p-3 text-sm text-red-700 dark:text-red-300">
                  {flash.alert}
                </div>
              )}
            </div>
          )}

          <main className="flex-1 p-4 pt-6">
            {children}
          </main>
        </SidebarInset>
      </SidebarProvider>
    </>
  )
}
