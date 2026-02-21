import { useForm, usePage } from '@inertiajs/react'
import { User, Mail, Shield, Calendar, Loader2 } from 'lucide-react'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { DashboardPageProps } from '@/types'

type Profile = {
  id: string
  name: string
  email_address: string
  role: 'member' | 'admin' | 'owner'
  created_at: string
}

type ProfileEditProps = {
  profile: Profile
}

function getRoleBadge(role: string) {
  switch (role) {
    case 'owner':
      return <Badge variant="default">Owner</Badge>
    case 'admin':
      return <Badge variant="secondary">Admin</Badge>
    default:
      return <Badge variant="outline">Member</Badge>
  }
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  })
}

export default function ProfileEdit({ profile }: ProfileEditProps) {
  const { auth } = usePage<DashboardPageProps>().props
  const accountSlug = auth.account?.slug

  const { data, setData, patch, processing, errors, isDirty } = useForm({
    name: profile.name,
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    patch(`/${accountSlug}/profile`)
  }

  return (
    <DashboardLayout title="Profile">
      <div className="max-w-2xl space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Profile</h1>
          <p className="text-muted-foreground mt-1">
            Manage your profile settings for this workspace
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Profile Information</CardTitle>
            <CardDescription>
              Update your display name and view your account details
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="name">Display Name</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="name"
                    type="text"
                    value={data.name}
                    onChange={(e) => setData('name', e.target.value)}
                    className="pl-10"
                    placeholder="Your name"
                    required
                  />
                </div>
                {errors.name && (
                  <p className="text-sm text-destructive">{errors.name}</p>
                )}
                <p className="text-xs text-muted-foreground">
                  This is how your name appears to other members in this workspace.
                </p>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={processing || !isDirty}>
                  {processing ? (
                    <span className="flex items-center gap-2">
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Saving...
                    </span>
                  ) : (
                    'Save Changes'
                  )}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Account Details</CardTitle>
            <CardDescription>
              Information about your account in this workspace
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between py-2">
              <div className="flex items-center gap-3">
                <Mail className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm font-medium">Email Address</p>
                  <p className="text-sm text-muted-foreground">{profile.email_address}</p>
                </div>
              </div>
            </div>

            <Separator />

            <div className="flex items-center justify-between py-2">
              <div className="flex items-center gap-3">
                <Shield className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm font-medium">Role</p>
                  <p className="text-sm text-muted-foreground">Your role in this workspace</p>
                </div>
              </div>
              {getRoleBadge(profile.role)}
            </div>

            <Separator />

            <div className="flex items-center justify-between py-2">
              <div className="flex items-center gap-3">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm font-medium">Member Since</p>
                  <p className="text-sm text-muted-foreground">{formatDate(profile.created_at)}</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-muted">
          <CardHeader>
            <CardTitle className="text-base">About Profiles</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              Your profile is specific to this workspace. If you're a member of multiple workspaces,
              you can have a different display name in each one. Your email address is shared across
              all workspaces and cannot be changed here.
            </p>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
