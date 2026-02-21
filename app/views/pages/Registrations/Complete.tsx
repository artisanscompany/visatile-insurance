import { useForm } from '@inertiajs/react'
import { CheckCircle2, Loader2 } from 'lucide-react'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'

type CompleteProps = {
  identity: {
    email_address: string
  }
}

export default function RegistrationsComplete({ identity }: CompleteProps) {
  const { data, setData, post, processing, errors } = useForm({
    name: '',
    account_name: ''
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post('/registration/completion')
  }

  return (
    <PublicLayout title="Complete Your Profile">
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
              <CheckCircle2 className="w-8 h-8 text-primary" />
            </div>
            <Badge variant="secondary" className="mb-2">Almost there!</Badge>
          </div>

          <Card className="border-0 shadow-xl">
            <CardHeader className="space-y-1 pb-4">
              <CardTitle className="text-2xl font-bold text-center">Complete your profile</CardTitle>
              <CardDescription className="text-center">
                Signed in as <span className="font-medium text-foreground">{identity.email_address}</span>
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="space-y-2">
                  <Label htmlFor="name">Your name</Label>
                  <Input
                    id="name"
                    type="text"
                    placeholder="Jane Doe"
                    value={data.name}
                    onChange={e => setData('name', e.target.value)}
                    autoComplete="name"
                    autoFocus
                    required
                    className="h-11"
                  />
                  {errors.name && (
                    <p className="text-sm text-destructive">{errors.name}</p>
                  )}
                </div>

                <Separator className="my-4" />

                <div className="space-y-2">
                  <Label htmlFor="account_name">Workspace name</Label>
                  <Input
                    id="account_name"
                    type="text"
                    placeholder="My Company or Personal"
                    value={data.account_name}
                    onChange={e => setData('account_name', e.target.value)}
                    required
                    className="h-11"
                  />
                  <p className="text-xs text-muted-foreground">
                    This will be the name of your workspace. You can change it later.
                  </p>
                  {errors.account_name && (
                    <p className="text-sm text-destructive">{errors.account_name}</p>
                  )}
                </div>

                <Button type="submit" className="w-full h-11 text-base font-medium" disabled={processing}>
                  {processing ? (
                    <span className="flex items-center gap-2">
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Creating workspace...
                    </span>
                  ) : (
                    'Create workspace'
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
