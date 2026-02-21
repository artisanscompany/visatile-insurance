# frozen_string_literal: true

module Registrations
  class CompletionsController < InertiaController
    disallow_account_scope
    allow_unauthenticated_access

    def show
      redirect_to new_session_path unless authenticated?
      render inertia: "Registrations/Complete", props: {
        identity: {
          email_address: Current.identity&.email_address
        }
      }
    end

    def create
      redirect_to new_session_path unless authenticated?

      account = Account.create_individual_for(
        identity: Current.identity,
        user_name: params.expect(:name),
        account_name: params.expect(:account_name)
      )

      Current.account = account
      Current.user = account.users.find_by(identity: Current.identity)

      redirect_to root_path, notice: "Welcome! Your workspace has been created."
    end
  end
end
