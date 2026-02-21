# frozen_string_literal: true

class AccountInertiaController < InertiaController
  # Base controller for all authenticated pages within an account scope
  # Requires both authentication and account context

  # Share sidebar data with all account-scoped Inertia responses
  inertia_share do
    {
      sidebar: {
        accounts: sidebar_accounts,
        permissions: sidebar_permissions
      }
    }
  end

  private

  def sidebar_accounts
    return [] unless Current.identity

    Current.identity.accounts
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
  end

  def sidebar_permissions
    {
      can_manage_members: Current.user&.can_manage_members? || false,
      can_view_settings: Current.user&.admin? || Current.user&.owner? || false,
      is_superuser: Current.identity&.superuser? || false
    }
  end
end
