class ApplicationController < ActionController::Base
  allow_browser versions: { safari: 15, chrome: 100, firefox: 100, opera: 90, ie: false }

  inertia_share do
    {
      flash: {
        notice: flash[:notice],
        alert: flash[:alert]
      },
      currentYear: Time.current.year
    }
  end
end
