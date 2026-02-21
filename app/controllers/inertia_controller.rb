# frozen_string_literal: true

class InertiaController < ApplicationController
  layout "inertia"

  # Share data with all Inertia responses
  inertia_share do
    {
      auth: {
        user: Current.user&.as_json(only: %i[id name role]),
        identity: Current.identity&.as_json(only: %i[id email_address]),
        account: Current.account&.as_json(only: %i[id name slug]),
        superuser: Current.identity&.superuser? || false
      },
      flash: {
        notice: flash[:notice],
        alert: flash[:alert],
        shake: flash[:shake],
        magic_link_code: flash[:magic_link_code]
      }
    }
  end
end
