module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_account
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    # For login/signup pages - redirect if already logged in
    def require_unauthenticated_access(**options)
      allow_unauthenticated_access(**options)
      before_action :redirect_authenticated_user, **options
    end

    # For public pages that optionally show user info
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :resume_session, **options
    end

    # For non-tenanted pages (login, account selector)
    def disallow_account_scope(**options)
      skip_before_action :require_account, **options
      before_action :redirect_tenanted_request, **options
    end
  end

  private

  def authenticated?
    Current.identity.present?
  end

  def require_account
    redirect_to_login_url unless Current.account.present?
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    if (session = find_session_by_cookie)
      set_current_session(session)
    end
  end

  def find_session_by_cookie
    session = Session.active.find_by(id: cookies.signed[:session_token])
    session&.refresh! if session && session_should_refresh?(session)
    session
  end

  def session_should_refresh?(session)
    # Refresh session if it's older than 1 day (extends expiration on activity)
    session.updated_at < 1.day.ago
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url if Current.account.present?
    redirect_to_login_url
  end

  def start_new_session_for(identity)
    identity.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      set_current_session(session)
    end
  end

  def set_current_session(session)
    Current.session = session
    cookies.signed.permanent[:session_token] = {
      value: session.id,
      httponly: true,
      same_site: :lax
    }
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_token)
  end

  def redirect_authenticated_user
    redirect_to after_authentication_url if authenticated?
  end

  def redirect_tenanted_request
    redirect_to new_session_path if Current.account.present?
  end

  def redirect_to_login_url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || account_selector_path
  end

  def store_pending_email(email)
    session[:pending_authentication_email] = email
  end

  def pending_authentication_email
    session[:pending_authentication_email]
  end

  def clear_pending_email
    session.delete(:pending_authentication_email)
  end

  def email_address_pending_authentication_matches?(email)
    pending_authentication_email.present? &&
      pending_authentication_email.downcase == email.to_s.downcase
  end

  # Development convenience - show magic link code in flash
  def serve_development_magic_link(magic_link)
    if Rails.env.development?
      flash[:magic_link_code] = magic_link&.code
    end
  end
end
