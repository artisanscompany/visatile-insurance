module SuperuserAuthorization
  extend ActiveSupport::Concern

  private

  def require_superuser
    unless Current.identity&.superuser?
      redirect_to dashboard_path, alert: "Not authorized."
    end
  end
end
