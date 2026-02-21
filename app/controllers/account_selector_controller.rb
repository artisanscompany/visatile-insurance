# frozen_string_literal: true

class AccountSelectorController < InertiaController
  disallow_account_scope
  allow_unauthenticated_access

  def show
    return redirect_to new_session_path unless authenticated?

    accounts = Current.identity
      .accounts
      .includes(:accountable)
      .order(:name)
      .map do |account|
        {
          id: account.id,
          name: account.name,
          slug: account.slug,
          type: account.accountable_type
        }
      end

    render inertia: "Accounts/Selector", props: {
      accounts: accounts
    }
  end
end
