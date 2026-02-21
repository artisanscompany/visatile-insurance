import { router } from '@inertiajs/react'
import { Building2, Plus, ChevronRight, LogOut } from 'lucide-react'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { AccountWithType } from '@/types'

type SelectorProps = {
  accounts: AccountWithType[]
}

export default function AccountsSelector({ accounts }: SelectorProps) {
  return (
    <PublicLayout title="Select Account">
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-muted/30 p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
              <Building2 className="w-8 h-8 text-primary" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">Select a workspace</h1>
            <p className="text-muted-foreground mt-1">Choose where you want to go</p>
          </div>

          <Card className="border-0 shadow-xl">
            <CardHeader className="space-y-1 pb-4">
              <CardTitle className="text-lg font-semibold text-center">Your workspaces</CardTitle>
              <CardDescription className="text-center">
                {accounts.length === 0
                  ? "You don't have any workspaces yet"
                  : `You have access to ${accounts.length} workspace${accounts.length > 1 ? 's' : ''}`
                }
              </CardDescription>
            </CardHeader>
            <CardContent>
              {accounts.length === 0 ? (
                <div className="text-center py-8">
                  <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center mx-auto mb-4">
                    <Plus className="w-8 h-8 text-muted-foreground" />
                  </div>
                  <p className="text-muted-foreground mb-4">Create your first workspace to get started</p>
                  <Button asChild>
                    <a href="/registration/completion">Create workspace</a>
                  </Button>
                </div>
              ) : (
                <div className="space-y-2">
                  {accounts.map(account => (
                    <a
                      key={account.id}
                      href={`/${account.slug}/dashboard`}
                      className="flex items-center gap-4 p-4 rounded-lg border-2 border-transparent hover:border-primary/20 hover:bg-muted/50 transition-all group"
                    >
                      <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary/20 to-primary/10 flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform">
                        <span className="text-xl font-bold text-primary">
                          {account.name.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold truncate">{account.name}</p>
                        <p className="text-sm text-muted-foreground truncate">/{account.slug}</p>
                      </div>
                      <Badge variant={account.type === 'IndividualAccount' ? 'secondary' : 'default'} className="shrink-0">
                        {account.type === 'IndividualAccount' ? 'Personal' : 'Team'}
                      </Badge>
                      <ChevronRight className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                    </a>
                  ))}
                </div>
              )}

              <Separator className="my-6" />

              <Button
                variant="ghost"
                className="w-full text-muted-foreground hover:text-foreground"
                onClick={() => router.delete('/session')}
              >
                <LogOut className="w-4 h-4 mr-2" />
                Sign out
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </PublicLayout>
  )
}
