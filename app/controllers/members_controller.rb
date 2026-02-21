# frozen_string_literal: true

class MembersController < AccountInertiaController
  before_action :require_manage_permission, only: %i[update destroy]
  before_action :set_member, only: %i[update destroy]

  def index
    members = Current.account.users
      .includes(:identity)
      .alphabetically
      .map { |user| member_json(user) }

    invites = Current.account.invites
      .pending
      .includes(:inviter)
      .order(created_at: :desc)
      .map { |invite| invite_json(invite) }

    render inertia: "Members/Index", props: {
      members: members,
      invites: invites
    }
  end

  def update
    unless Current.user.can_change_roles?
      return redirect_back(
        fallback_location: members_path,
        alert: "Only the owner can change member roles."
      )
    end

    new_role = params.require(:role)
    unless %w[member admin].include?(new_role)
      return redirect_back(
        fallback_location: members_path,
        alert: "Invalid role."
      )
    end

    if @member.owner?
      return redirect_back(
        fallback_location: members_path,
        alert: "Cannot change the owner's role."
      )
    end

    @member.update!(role: new_role)
    redirect_to members_path, notice: "#{@member.name}'s role updated to #{new_role}."
  end

  def destroy
    unless Current.user.can_remove_member?(@member)
      return redirect_back(
        fallback_location: members_path,
        alert: "You cannot remove this member."
      )
    end

    @member.destroy!
    redirect_to members_path, notice: "#{@member.name} has been removed from the workspace."
  end

  private

  def require_manage_permission
    return if Current.user.can_manage_members?

    redirect_to members_path, alert: "You don't have permission to manage members."
  end

  def set_member
    @member = Current.account.users.find(params[:id])
  end

  def member_json(user)
    {
      id: user.id,
      name: user.name,
      email_address: user.identity.email_address,
      role: user.role,
      created_at: user.created_at.iso8601
    }
  end

  def invite_json(invite)
    {
      id: invite.id,
      email: invite.email,
      role: invite.role,
      expires_at: invite.expires_at.iso8601,
      inviter_name: invite.inviter.name
    }
  end
end
