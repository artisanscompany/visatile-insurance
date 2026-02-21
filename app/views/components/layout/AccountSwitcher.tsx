import { ChevronsUpDown, Plus, Building2, User } from 'lucide-react'
import { usePage } from '@inertiajs/react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from '@/components/ui/sidebar'
import { DashboardPageProps, SidebarAccount } from '@/types'

export function AccountSwitcher() {
  const { isMobile } = useSidebar()
  const { auth, sidebar } = usePage<DashboardPageProps>().props
  const currentAccount = auth.account
  const accounts = sidebar?.accounts || []

  const currentAccountData = accounts.find(a => a.id === currentAccount?.id)
  const isTeam = currentAccountData?.type === 'TeamAccount'

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton
              size="lg"
              className="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground"
            >
              <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
                {isTeam ? (
                  <Building2 className="size-4" />
                ) : (
                  <User className="size-4" />
                )}
              </div>
              <div className="grid flex-1 text-left text-sm leading-tight">
                <span className="truncate font-semibold">
                  {currentAccount?.name || 'Select workspace'}
                </span>
                <span className="truncate text-xs text-muted-foreground">
                  {isTeam ? 'Team' : 'Personal'}
                </span>
              </div>
              <ChevronsUpDown className="ml-auto" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            className="w-[--radix-dropdown-menu-trigger-width] min-w-56 rounded-lg"
            align="start"
            side={isMobile ? 'bottom' : 'right'}
            sideOffset={4}
          >
            <DropdownMenuLabel className="text-xs text-muted-foreground">
              Workspaces
            </DropdownMenuLabel>
            {accounts.map((account) => (
              <DropdownMenuItem
                key={account.id}
                asChild
                className="gap-2 p-2"
              >
                <a href={`/${account.slug}/dashboard`}>
                  <div className="flex size-6 items-center justify-center rounded-sm border">
                    {account.type === 'TeamAccount' ? (
                      <Building2 className="size-4 shrink-0" />
                    ) : (
                      <User className="size-4 shrink-0" />
                    )}
                  </div>
                  <span className="truncate">{account.name}</span>
                  {account.id === currentAccount?.id && (
                    <span className="ml-auto text-xs text-muted-foreground">Current</span>
                  )}
                </a>
              </DropdownMenuItem>
            ))}
            <DropdownMenuSeparator />
            <DropdownMenuItem asChild className="gap-2 p-2">
              <a href="/registration/completion">
                <div className="flex size-6 items-center justify-center rounded-md border bg-background">
                  <Plus className="size-4" />
                </div>
                <span className="font-medium text-muted-foreground">Create workspace</span>
              </a>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}
