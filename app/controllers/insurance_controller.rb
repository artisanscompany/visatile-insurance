# frozen_string_literal: true

class InsuranceController < InertiaController
  disallow_account_scope
  allow_unauthenticated_access

  private

  def insurance_session
    session[:insurance_flow] ||= {}
  end

  def require_quote_data
    unless insurance_session["quote_response"].present?
      redirect_to new_insurance_quote_path, alert: "Please start with a quote."
    end
  end

  def require_traveler_data
    unless insurance_session["travelers"].present?
      redirect_to new_insurance_traveler_detail_path, alert: "Please fill in traveler details."
    end
  end
end
