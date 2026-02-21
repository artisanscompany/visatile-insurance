export type FlashData = {
  notice?: string
  alert?: string
  shake?: number  // Timestamp for triggering input clearing on error
  magic_link_code?: string
}

// Auth types
export type User = {
  id: string
  name: string
  role: 'member' | 'admin' | 'owner'
}

export type Identity = {
  id: string
  email_address: string
}

export type Account = {
  id: string
  name: string
  slug: string
}

export type AccountWithType = Account & {
  type: 'IndividualAccount' | 'TeamAccount'
}

export type AuthData = {
  user: User | null
  identity: Identity | null
  account: Account | null
  superuser: boolean
}

// Sidebar types
export type SidebarAccount = {
  id: string
  name: string
  slug: string
  type: 'IndividualAccount' | 'TeamAccount'
}

export type SidebarPermissions = {
  can_manage_members: boolean
  can_view_settings: boolean
  is_superuser: boolean
}

export type SidebarData = {
  accounts: SidebarAccount[]
  permissions: SidebarPermissions
}

// Member and invite types
export type Member = {
  id: string
  name: string
  email_address: string
  role: 'member' | 'admin' | 'owner'
  created_at: string
}

export type Invite = {
  id: string
  email: string
  role: 'member' | 'admin'
  expires_at: string
  inviter_name: string
}

export type InviteDetails = {
  token: string
  email: string
  role: string
  account_name: string
  inviter_name: string
  expires_at: string
}

export type SharedProps = {
  auth: AuthData
  flash: FlashData
}

// Dashboard shared props (includes sidebar data)
export type DashboardSharedProps = SharedProps & {
  sidebar: SidebarData
}

// Base type for all pages
export type PageProps<T = Record<string, unknown>> = SharedProps & T

// Dashboard page props
export type DashboardPageProps<T = Record<string, unknown>> = DashboardSharedProps & T

// Insurance types
export type CoverageTier = 1 | 2 | 3

export type QuoteRequest = {
  start_date: string
  end_date: string
  departure_country: string
  destination_countries: string[]
  coverage_tier: CoverageTier
  traveler_birth_dates: string[]
}

export type QuoteResponse = {
  tariff_id: number
  tariff_name: string
  price_amount: string
  price_currency: string
  coverage_tier: CoverageTier
  start_date: string
  end_date: string
  traveler_count: number
  locality_coverage: number
}

export type TravelerData = {
  first_name: string
  last_name: string
  birth_date: string
  passport_number: string
  passport_country: string
}

export type TravelerDetail = TravelerData & {
  id: string
}

export type PolicySummary = {
  id: string
  start_date: string
  end_date: string
  departure_country: string
  destination_countries: string[]
  coverage_tier: CoverageTier
  coverage_label: string
  price_amount: number
  price_currency: string
  current_state: string
  created_at: string
}

export type PolicyDetail = PolicySummary & {
  locality_coverage: number
}

export type PolicyStateEntry = {
  state: string
  created_at: string
  details: Record<string, string | number>
}

export type FailedPolicySummary = {
  id: string
  start_date: string
  end_date: string
  price_amount: number
  price_currency: string
  coverage_label: string
  failed_step: string
  error_message: string
  failed_at: string
}
