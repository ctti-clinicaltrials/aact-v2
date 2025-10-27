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
      redirect_to settings_database_access_path, notice: "Welcome! Your account has been created. Set up database access to get started."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
  end
end
