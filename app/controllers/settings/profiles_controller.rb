class Settings::ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(profile_params)
      redirect_to settings_profile_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.expect(user: [ :name, :email_address ])
  end
end
