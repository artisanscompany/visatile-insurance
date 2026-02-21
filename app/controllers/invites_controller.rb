# frozen_string_literal: true

class InvitesController < AccountInertiaController
  rate_limit to: 5, within: 1.hour, only: :create,
    with: -> { redirect_to members_path, alert: "Too many invitations. Try again later." }

  before_action :require_manage_permission
  before_action :set_invite, only: :destroy

  def create
    email = invite_params[:email]&.strip&.downcase
    role = invite_params[:role] || "member"

    # Check if already a member
    if Current.account.identities.exists?(email_address: email)
      return redirect_back(
        fallback_location: members_path,
        alert: "This person is already a member of this workspace."
      )
    end

    # Check for existing pending invite
    existing = Current.account.invites.pending.find_by(email: email)
    if existing
      return redirect_back(
        fallback_location: members_path,
        alert: "An invitation has already been sent to this email."
      )
    end

    invite = Current.account.invites.build(
      email: email,
      role: role,
      inviter: Current.user
    )

    if invite.save
      InviteMailer.invitation(invite).deliver_later
      redirect_to members_path, notice: "Invitation sent to #{email}."
    else
      redirect_back(
        fallback_location: members_path,
        alert: invite.errors.full_messages.first || "Failed to send invitation."
      )
    end
  end

  def destroy
    @invite.destroy!
    redirect_to members_path, notice: "Invitation to #{@invite.email} has been cancelled."
  end

  private

  def require_manage_permission
    return if Current.user.can_manage_members?

    redirect_to members_path, alert: "You don't have permission to manage invitations."
  end

  def set_invite
    @invite = Current.account.invites.pending.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to members_path, alert: "Invitation not found or already accepted."
  end

  def invite_params
    params.require(:invite).permit(:email, :role)
  end
end
