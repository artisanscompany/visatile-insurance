class ApplicationController < ActionController::Base
  include CurrentRequest
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
