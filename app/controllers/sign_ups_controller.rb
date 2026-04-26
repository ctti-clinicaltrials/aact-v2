class SignUpsController < ApplicationController
  unauthenticated_access_only
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, alert: "Try again later." }

  def show
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to settings_database_access_path, notice: "Welcome! Your account has been created successfully."
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.expect(user: [ :first_name, :last_name, :email_address, :password, :password_confirmation ])
  end
end
