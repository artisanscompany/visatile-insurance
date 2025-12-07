module DeviceVariant
  extend ActiveSupport::Concern

  included do
    before_action :set_variant
  end

  private

  def set_variant
    # Allow forcing variant via query param in development
    if Rails.env.development? && params[:variant].present?
      request.variant = params[:variant].to_sym
    elsif mobile_device?
      request.variant = :mobile
    else
      request.variant = :desktop
    end
  end

  def mobile_device?
    agent = request.user_agent.to_s.downcase
    agent.match?(/mobile|android|iphone|ipad|ipod|blackberry|iemobile|opera mini/)
  end
end
