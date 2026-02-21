# frozen_string_literal: true

class ProfilesController < AccountInertiaController
  def edit
    render inertia: "Profile/Edit", props: {
      profile: profile_props
    }
  end

  def update
    if Current.user.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile updated successfully."
    else
      redirect_to edit_profile_path, alert: Current.user.errors.full_messages.first
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name)
  end

  def profile_props
    {
      id: Current.user.id,
      name: Current.user.name,
      email_address: Current.identity&.email_address,
      role: Current.user.role,
      created_at: Current.user.created_at.iso8601
    }
  end
end
