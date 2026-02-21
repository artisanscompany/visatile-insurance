import { useForm } from '@inertiajs/react'
import { UserPlus, Loader2 } from 'lucide-react'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'

type NewProps = {
  email?: string
}

export default function RegistrationsNew({ email }: NewProps) {
  const { data, setData, post, processing, errors } = useForm({
    email_address: email || ''
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    post('/registration')
  }

  return (
    <PublicLayout title="Create Account">
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
              <UserPlus className="w-8 h-8 text-primary" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">Create your account</h1>
            <p className="text-muted-foreground mt-1">Get started in just a few steps</p>
          </div>

          <Card className="border-0 shadow-xl">
            <CardHeader className="space-y-1 pb-4">
              <CardTitle className="text-xl font-semibold text-center">Sign up with email</CardTitle>
              <CardDescription className="text-center">
                We'll send you a verification code to get started
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
                    'Continue'
                  )}
                </Button>
              </form>

              <div className="relative my-6">
                <Separator />
                <span className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-card px-2 text-xs text-muted-foreground">
                  Already a member?
                </span>
              </div>

              <p className="text-center text-sm text-muted-foreground">
                Have an account?{' '}
                <a href="/session/new" className="text-primary hover:underline font-medium">
                  Sign in
                </a>
              </p>
            </CardContent>
          </Card>

          <p className="text-center text-xs text-muted-foreground mt-6">
            By continuing, you agree to our Terms of Service and Privacy Policy.
          </p>
        </div>
      </div>
    </PublicLayout>
  )
}
