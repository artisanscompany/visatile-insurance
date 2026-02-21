import { useForm } from '@inertiajs/react'
import { KeyRound, Loader2 } from 'lucide-react'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'

export default function SessionsNew() {
  const { data, setData, post, processing, errors } = useForm({
    email_address: ''
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post('/session')
  }

  return (
    <PublicLayout title="Sign In">
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
              <KeyRound className="w-8 h-8 text-primary" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">Welcome back</h1>
            <p className="text-muted-foreground mt-1">Sign in to your account</p>
          </div>

          <Card className="border-0 shadow-xl">
            <CardHeader className="space-y-1 pb-4">
              <CardTitle className="text-xl font-semibold text-center">Sign in with email</CardTitle>
              <CardDescription className="text-center">
                We'll send you a magic code to sign in instantly
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="space-y-2">
                  <Label htmlFor="email_address">Email address</Label>
                  <Input
                    id="email_address"
                    type="email"
                    placeholder="you@example.com"
                    value={data.email_address}
                    onChange={e => setData('email_address', e.target.value)}
                    autoComplete="email"
                    autoFocus
                    required
                    className="h-11"
                  />
                  {errors.email_address && (
                    <p className="text-sm text-destructive">{errors.email_address}</p>
                  )}
                </div>
                <Button type="submit" className="w-full h-11 text-base font-medium" disabled={processing}>
                  {processing ? (
                    <span className="flex items-center gap-2">
                      <Loader2 className="animate-spin h-4 w-4" />
                      Sending code...
                    </span>
                  ) : (
                    'Continue with email'
                  )}
                </Button>
              </form>

              <div className="relative my-6">
                <Separator />
                <span className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-card px-2 text-xs text-muted-foreground">
                  New here?
                </span>
              </div>

              <p className="text-center text-sm text-muted-foreground">
                Don't have an account?{' '}
                <a href="/registration/new" className="text-primary hover:underline font-medium">
                  Create one
                </a>
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </PublicLayout>
  )
}
