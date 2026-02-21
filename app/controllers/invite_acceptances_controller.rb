# frozen_string_literal: true

class InviteAcceptancesController < InertiaController
  disallow_account_scope
  allow_unauthenticated_access

  before_action :set_invite

  def show
    # If user is logged in and their identity matches the invite email
    if Current.identity && Current.identity.email_address == @invite.email
      render inertia: "Invites/Accept", props: {
        invite: invite_props,
        identity: {
          email_address: Current.identity.email_address
        },
        needs_name: true
      }
    else
      # User needs to authenticate first
      render inertia: "Invites/Accept", props: {
        invite: invite_props,
        identity: nil,
        needs_name: false
      }
    end
  end

  def create
    # Check if already authenticated with matching identity
    unless Current.identity && Current.identity.email_address == @invite.email
      # Not authenticated or wrong identity - start magic link flow
      identity = Identity.find_or_create_by!(email_address: @invite.email)
      magic_link = identity.magic_links.create!

      MagicLinkMailer.sign_in_instructions(magic_link).deliver_later

      # Store the invite token and pending email in session for after authentication
      session[:pending_invite_token] = @invite.token
      store_pending_email(@invite.email)

      if Rails.env.development?
        redirect_to session_magic_link_path, flash: {
          notice: "Check your email for a sign-in link.",
          magic_link_code: magic_link.code
        }
      else
        redirect_to session_magic_link_path, flash: {
          notice: "Check your email for a sign-in link."
        }
      end
      return
    end

    # Authenticated with correct identity - accept the invite
    name = params.require(:name)

    @invite.accept!(identity: Current.identity, user_name: name)

    # Clear any pending invite token
    session.delete(:pending_invite_token)

    # Redirect to the new workspace
    redirect_to "/#{@invite.account.slug}/dashboard", notice: "Welcome to #{@invite.account.name}!"
  end

  private

  def set_invite
    @invite = Invite.pending.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "This invitation is invalid or has expired."
  end

  def invite_props
    {
      token: @invite.token,
      email: @invite.email,
      role: @invite.role,
      account_name: @invite.account.name,
      inviter_name: @invite.inviter.name,
      expires_at: @invite.expires_at.iso8601
    }
  end
end
