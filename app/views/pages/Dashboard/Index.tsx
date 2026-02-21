import { usePage } from '@inertiajs/react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
import { DashboardPageProps } from '@/types'

type DashboardStats = {
  total_assets: number
  team_members: number
  storage_used: string
}

type DashboardIndexProps = {
  stats: DashboardStats
}

export default function DashboardIndex({ stats }: DashboardIndexProps) {
  const { auth } = usePage<DashboardPageProps>().props

  return (
    <DashboardLayout title="Dashboard">
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Welcome back, {auth.user?.name}
          </h1>
          <p className="text-muted-foreground mt-1">
            Here's what's happening in {auth.account?.name}
          </p>
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <Card>
            <CardHeader>
              <CardTitle>Total Assets</CardTitle>
              <CardDescription>Assets in your workspace</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.total_assets}</div>
              <p className="text-xs text-muted-foreground">
                {stats.total_assets === 0 ? 'No assets yet' : 'Across all collections'}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Team Members</CardTitle>
              <CardDescription>People with access</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.team_members}</div>
              <p className="text-xs text-muted-foreground">
                {stats.team_members === 1 ? "That's you!" : `${stats.team_members} people in this workspace`}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Storage Used</CardTitle>
              <CardDescription>Total storage consumption</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.storage_used}</div>
              <p className="text-xs text-muted-foreground">
                {stats.storage_used === '0 MB' ? 'Ready to upload' : 'Total usage'}
              </p>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Getting Started</CardTitle>
            <CardDescription>
              Quick actions to set up your workspace
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="rounded-lg border p-4">
                <h3 className="font-semibold mb-1">Upload Assets</h3>
                <p className="text-sm text-muted-foreground mb-3">
                  Start by uploading your first asset to the workspace.
                </p>
                <a
                  href={`/${auth.account?.slug}/assets`}
                  className="text-sm text-primary hover:underline"
                >
                  Go to Assets →
                </a>
              </div>
              <div className="rounded-lg border p-4">
                <h3 className="font-semibold mb-1">Invite Team Members</h3>
                <p className="text-sm text-muted-foreground mb-3">
                  Collaborate by inviting others to your workspace.
                </p>
                <a
                  href={`/${auth.account?.slug}/members`}
                  className="text-sm text-primary hover:underline"
                >
                  Manage Members →
                </a>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
