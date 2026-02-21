# frozen_string_literal: true

class DashboardController < AccountInertiaController
  def show
    render inertia: "Dashboard/Index", props: {
      stats: {
        total_assets: 0, # TODO: Replace with actual asset count when assets are implemented
        team_members: Current.account.users.count,
        storage_used: "0 MB" # TODO: Replace with actual storage usage when implemented
      }
    }
  end
end
