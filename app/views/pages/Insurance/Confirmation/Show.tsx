import { router } from '@inertiajs/react'
import { CheckCircle2, LogIn } from 'lucide-react'
import { FunnelLayout } from '@/components/layout/FunnelLayout'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'

type ConfirmationShowProps = {
  policy_id: string
  session_id: string
}

export default function ConfirmationShow({ policy_id, session_id }: ConfirmationShowProps) {
  return (
    <FunnelLayout title="Policy Confirmed" currentStep={4}>
      <div className="space-y-6">
        <Card>
          <CardContent className="pt-8 pb-8">
            <div className="text-center space-y-4">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 dark:bg-green-950/30">
                <CheckCircle2 className="h-8 w-8 text-green-600 dark:text-green-400" />
              </div>

              <div>
                <h1 className="text-2xl font-bold tracking-tight">
                  Your Policy is Confirmed!
                </h1>
                <p className="text-muted-foreground mt-2">
                  Your travel insurance policy has been successfully created.
                </p>
              </div>

              <Separator className="my-6" />

              <div className="space-y-2">
                <p className="text-sm text-muted-foreground">Policy ID</p>
                <p className="text-lg font-mono font-semibold">{policy_id}</p>
              </div>

              <div className="space-y-2">
                <p className="text-sm text-muted-foreground">Session ID</p>
                <p className="text-sm font-mono text-muted-foreground">{session_id}</p>
              </div>

              <Separator className="my-6" />

              <p className="text-sm text-muted-foreground">
                You'll receive a confirmation email shortly with your full policy details
                and documentation.
              </p>

              <div className="pt-4">
                <Button
                  variant="outline"
                  className="h-11"
                  onClick={() => router.visit('/session/new')}
                >
                  <LogIn className="mr-2 h-4 w-4" />
                  Sign In to Your Account
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </FunnelLayout>
  )
}
