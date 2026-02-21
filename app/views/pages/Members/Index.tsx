import { useState } from 'react'
import { router, usePage } from '@inertiajs/react'
import { MoreHorizontal, Mail, Clock, UserX, RefreshCw, Shield, ShieldCheck, Crown } from 'lucide-react'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { InviteMemberDialog } from './InviteMemberDialog'
import { DashboardPageProps, Member, Invite } from '@/types'

type MembersIndexProps = {
  members: Member[]
  invites: Invite[]
}

type ConfirmDialogState = {
  open: boolean
  title: string
  description: string
  onConfirm: () => void
}

function getRoleBadge(role: string) {
  switch (role) {
    case 'owner':
      return <Badge variant="default" className="gap-1"><Crown className="h-3 w-3" />Owner</Badge>
    case 'admin':
      return <Badge variant="secondary" className="gap-1"><ShieldCheck className="h-3 w-3" />Admin</Badge>
    default:
      return <Badge variant="outline" className="gap-1"><Shield className="h-3 w-3" />Member</Badge>
  }
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

function getInitials(name: string) {
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

export default function MembersIndex({ members, invites }: MembersIndexProps) {
  const { auth, sidebar } = usePage<DashboardPageProps>().props
  const [inviteDialogOpen, setInviteDialogOpen] = useState(false)
  const [confirmDialog, setConfirmDialog] = useState<ConfirmDialogState>({
    open: false,
    title: '',
    description: '',
    onConfirm: () => {},
  })

  const accountSlug = auth.account?.slug
  const canManageMembers = sidebar?.permissions?.can_manage_members
  const canChangeRoles = auth.user?.role === 'owner'

  const closeConfirmDialog = () => {
    setConfirmDialog(prev => ({ ...prev, open: false }))
  }

  const handleChangeRole = (memberId: string, newRole: string) => {
    router.patch(`/${accountSlug}/members/${memberId}`, { role: newRole }, {
      preserveScroll: true,
    })
  }

  const handleRemoveMember = (memberId: string, memberName: string) => {
    setConfirmDialog({
      open: true,
      title: 'Remove Member',
      description: `Are you sure you want to remove ${memberName} from this workspace? This action cannot be undone.`,
      onConfirm: () => {
        router.delete(`/${accountSlug}/members/${memberId}`, {
          preserveScroll: true,
        })
        closeConfirmDialog()
      },
    })
  }

  const handleCancelInvite = (inviteId: string, inviteEmail: string) => {
    setConfirmDialog({
      open: true,
      title: 'Cancel Invitation',
      description: `Are you sure you want to cancel the invitation to ${inviteEmail}?`,
      onConfirm: () => {
        router.delete(`/${accountSlug}/invites/${inviteId}`, {
          preserveScroll: true,
        })
        closeConfirmDialog()
      },
    })
  }

  const handleResendInvite = (inviteId: string) => {
    router.post(`/${accountSlug}/invites/${inviteId}/resend`, {}, {
      preserveScroll: true,
    })
  }

  return (
    <DashboardLayout title="Members">
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Members</h1>
            <p className="text-muted-foreground mt-1">
              Manage who has access to this workspace
            </p>
          </div>
          {canManageMembers && (
            <Button onClick={() => setInviteDialogOpen(true)}>
              <Mail className="mr-2 h-4 w-4" />
              Invite Member
            </Button>
          )}
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Team Members</CardTitle>
            <CardDescription>
              {members.length} member{members.length !== 1 ? 's' : ''} in this workspace
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Member</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Joined</TableHead>
                  {canManageMembers && <TableHead className="w-[50px]" />}
                </TableRow>
              </TableHeader>
              <TableBody>
                {members.map((member) => (
                  <TableRow key={member.id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Avatar className="h-8 w-8">
                          <AvatarFallback>{getInitials(member.name)}</AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">{member.name}</div>
                          <div className="text-sm text-muted-foreground">{member.email_address}</div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{getRoleBadge(member.role)}</TableCell>
                    <TableCell className="text-muted-foreground">
                      {formatDate(member.created_at)}
                    </TableCell>
                    {canManageMembers && (
                      <TableCell>
                        {member.id !== auth.user?.id && member.role !== 'owner' && (
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                                <span className="sr-only">Actions</span>
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuLabel>Actions</DropdownMenuLabel>
                              {canChangeRoles && (
                                <>
                                  <DropdownMenuSeparator />
                                  <DropdownMenuItem
                                    onClick={() => handleChangeRole(member.id, member.role === 'admin' ? 'member' : 'admin')}
                                  >
                                    {member.role === 'admin' ? 'Demote to Member' : 'Promote to Admin'}
                                  </DropdownMenuItem>
                                </>
                              )}
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                className="text-destructive"
                                onClick={() => handleRemoveMember(member.id, member.name)}
                              >
                                <UserX className="mr-2 h-4 w-4" />
                                Remove Member
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        )}
                      </TableCell>
                    )}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {invites.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Pending Invitations</CardTitle>
              <CardDescription>
                {invites.length} pending invitation{invites.length !== 1 ? 's' : ''}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Email</TableHead>
                    <TableHead>Role</TableHead>
                    <TableHead>Invited By</TableHead>
                    <TableHead>Expires</TableHead>
                    {canManageMembers && <TableHead className="w-[50px]" />}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {invites.map((invite) => (
                    <TableRow key={invite.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <div className="h-8 w-8 rounded-full bg-muted flex items-center justify-center">
                            <Mail className="h-4 w-4 text-muted-foreground" />
                          </div>
                          <span className="font-medium">{invite.email}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="capitalize">{invite.role}</Badge>
                      </TableCell>
                      <TableCell className="text-muted-foreground">{invite.inviter_name}</TableCell>
                      <TableCell className="text-muted-foreground">
                        <div className="flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {formatDate(invite.expires_at)}
                        </div>
                      </TableCell>
                      {canManageMembers && (
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                                <span className="sr-only">Actions</span>
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuLabel>Actions</DropdownMenuLabel>
                              <DropdownMenuItem onClick={() => handleResendInvite(invite.id)}>
                                <RefreshCw className="mr-2 h-4 w-4" />
                                Resend Invitation
                              </DropdownMenuItem>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                className="text-destructive"
                                onClick={() => handleCancelInvite(invite.id, invite.email)}
                              >
                                <UserX className="mr-2 h-4 w-4" />
                                Cancel Invitation
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        )}

        <InviteMemberDialog
          open={inviteDialogOpen}
          onOpenChange={setInviteDialogOpen}
        />

        <AlertDialog open={confirmDialog.open} onOpenChange={(open) => !open && closeConfirmDialog()}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>{confirmDialog.title}</AlertDialogTitle>
              <AlertDialogDescription>{confirmDialog.description}</AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction onClick={confirmDialog.onConfirm}>
                Continue
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>
    </DashboardLayout>
  )
}
