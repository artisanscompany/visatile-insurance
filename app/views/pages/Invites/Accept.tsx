import { useState } from 'react'
import { router, useForm } from '@inertiajs/react'
import { Building2, Loader2, Mail } from 'lucide-react'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { InviteDetails, Identity } from '@/types'

type AcceptProps = {
  invite: InviteDetails
  identity: Identity | null
  needs_name: boolean
}

export default function InvitesAccept({ invite, identity, needs_name }: AcceptProps) {
  const [verifying, setVerifying] = useState(false)
  const { data, setData, post, processing, errors } = useForm({
    name: '',
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post(`/invites/${invite.token}/accept`)
  }

  const handleVerifyEmail = () => {
    setVerifying(true)
    router.post(`/invites/${invite.token}/accept`, {}, {
      onFinish: () => setVerifying(false)
    })
  }

  // User is not authenticated - show sign in prompt
  if (!identity) {
    return (
      <PublicLayout title="Accept Invitation">
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
          <div className="w-full max-w-md">
            <div className="text-center mb-8">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
                <Building2 className="w-8 h-8 text-primary" />
              </div>
              <h1 className="text-2xl font-bold tracking-tight">You're invited!</h1>
              <p className="text-muted-foreground mt-1">
                Join <span className="font-medium text-foreground">{invite.account_name}</span>
              </p>
            </div>

            <Card className="border-0 shadow-xl">
              <CardHeader className="space-y-1 pb-4">
                <CardTitle className="text-lg font-semibold text-center">Invitation Details</CardTitle>
                <CardDescription className="text-center">
                  {invite.inviter_name} invited you to join their workspace
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="rounded-lg border p-4 space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-muted-foreground">Workspace</span>
                    <span className="font-medium">{invite.account_name}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-muted-foreground">Your email</span>
                    <span className="font-medium">{invite.email}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-muted-foreground">Role</span>
                    <Badge variant="outline" className="capitalize">{invite.role}</Badge>
                  </div>
                </div>

                <div className="text-center">
                  <p className="text-sm text-muted-foreground mb-4">
                    To accept this invitation, you need to verify your email address.
                  </p>
                  <Button onClick={handleVerifyEmail} disabled={verifying} className="w-full">
                    {verifying ? (
                      <span className="flex items-center gap-2">
                        <Loader2 className="h-4 w-4 animate-spin" />
                        Sending...
                      </span>
                    ) : (
                      <>
                        <Mail className="mr-2 h-4 w-4" />
                        Continue with {invite.email}
                      </>
                    )}
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </PublicLayout>
    )
  }

  // User is authenticated and needs to provide their name
  return (
    <PublicLayout title="Accept Invitation">
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
              <Building2 className="w-8 h-8 text-primary" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">Almost there!</h1>
            <p className="text-muted-foreground mt-1">
              Complete your profile to join <span className="font-medium text-foreground">{invite.account_name}</span>
            </p>
          </div>

          <Card className="border-0 shadow-xl">
            <CardHeader className="space-y-1 pb-4">
              <CardTitle className="text-lg font-semibold text-center">Join Workspace</CardTitle>
              <CardDescription className="text-center">
                You're joining as <Badge variant="outline" className="ml-1 capitalize">{invite.role}</Badge>
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    value={identity.email_address}
                    disabled
                    className="bg-muted"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="name">Your name</Label>
                  <Input
                    id="name"
                    type="text"
                    placeholder="How should we call you?"
                    value={data.name}
                    onChange={(e) => setData('name', e.target.value)}
                    autoFocus
                    required
                    className="h-11"
                  />
                  {errors.name && (
                    <p className="text-sm text-destructive">{errors.name}</p>
                  )}
                  <p className="text-xs text-muted-foreground">
                    This is how your name will appear to other members.
                  </p>
                </div>
                <Button type="submit" className="w-full h-11 text-base font-medium" disabled={processing}>
                  {processing ? (
                    <span className="flex items-center gap-2">
                      <Loader2 className="animate-spin h-4 w-4" />
                      Joining...
                    </span>
                  ) : (
                    'Join Workspace'
                  )}
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </PublicLayout>
  )
}
