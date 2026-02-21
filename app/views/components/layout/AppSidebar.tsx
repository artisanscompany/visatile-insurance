import { Home, Users, Settings, FolderOpen, Shield, AlertTriangle } from 'lucide-react'
import { usePage } from '@inertiajs/react'
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail,
} from '@/components/ui/sidebar'
import { AccountSwitcher } from './AccountSwitcher'
import { NavUser } from './NavUser'
import { DashboardPageProps } from '@/types'

type NavItem = {
  title: string
  url: string
  icon: React.ComponentType<{ className?: string }>
  requiresPermission?: 'can_manage_members' | 'can_view_settings' | 'is_superuser'
}

export function AppSidebar(props: React.ComponentProps<typeof Sidebar>) {
  const { auth, sidebar } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug
  const permissions = sidebar?.permissions || {}

  const mainNavItems: NavItem[] = [
    {
      title: 'Dashboard',
      url: `/${accountSlug}/dashboard`,
      icon: Home,
    },
    {
      title: 'Assets',
      url: `/${accountSlug}/assets`,
      icon: FolderOpen,
    },
    {
      title: 'Policies',
      url: `/${accountSlug}/insurance_policies`,
      icon: Shield,
    },
  ]

  const settingsNavItems: NavItem[] = [
    {
      title: 'Members',
      url: `/${accountSlug}/members`,
      icon: Users,
      requiresPermission: 'can_manage_members',
    },
    {
      title: 'Settings',
      url: `/${accountSlug}/settings`,
      icon: Settings,
      requiresPermission: 'can_view_settings',
    },
    {
      title: 'Failed Policies',
      url: `/${accountSlug}/admin/failed_policies`,
      icon: AlertTriangle,
      requiresPermission: 'is_superuser' as const,
    },
  ]

  const visibleSettingsItems = settingsNavItems.filter(item => {
    if (!item.requiresPermission) return true
    return permissions[item.requiresPermission]
  })

  // Get current path for active state
  const currentPath = typeof window !== 'undefined' ? window.location.pathname : ''

  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <AccountSwitcher />
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Navigation</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {mainNavItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton
                    asChild
                    isActive={currentPath === item.url}
                    tooltip={item.title}
                  >
                    <a href={item.url}>
                      <item.icon className="size-4" />
                      <span>{item.title}</span>
                    </a>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {visibleSettingsItems.length > 0 && (
          <SidebarGroup>
            <SidebarGroupLabel>Settings</SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {visibleSettingsItems.map((item) => (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton
                      asChild
                      isActive={currentPath === item.url}
                      tooltip={item.title}
                    >
                      <a href={item.url}>
                        <item.icon className="size-4" />
                        <span>{item.title}</span>
                      </a>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        )}
      </SidebarContent>
      <SidebarFooter>
        <NavUser />
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}
