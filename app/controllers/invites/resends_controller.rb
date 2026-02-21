# frozen_string_literal: true

module Invites
  class ResendsController < AccountInertiaController
    rate_limit to: 5, within: 1.hour, only: :create,
      with: -> { redirect_to members_path, alert: "Too many invitations. Try again later." }

    before_action :require_manage_permission

    def create
      invite = Current.account.invites.pending.find(params[:invite_id])
      invite.update!(expires_at: Invite::EXPIRATION_PERIOD.from_now) if invite.expired?

      InviteMailer.invitation(invite).deliver_later
      redirect_to members_path, notice: "Invitation resent to #{invite.email}."
    rescue ActiveRecord::RecordNotFound
      redirect_to members_path, alert: "Invitation not found or already accepted."
    end

    private

    def require_manage_permission
      return if Current.user.can_manage_members?

      redirect_to members_path, alert: "You don't have permission to manage invitations."
    end
  end
end
