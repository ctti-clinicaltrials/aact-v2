class Settings::PasswordsController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user
  end

  # TODO: review and unify with password controller and forgot password flow

  def update
    @user = Current.user

    if @user.authenticate(params[:current_password])
      if @user.update(password_params)
        redirect_to settings_password_path, notice: "Password updated successfully."
      else
        flash.now[:alert] = @user.errors.full_messages.join(", ")
        render :show, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Current password is incorrect."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.expect(user: [ :password, :password_confirmation ])
  end
end
