class SignUpsController < ApplicationController
  unauthenticated_access_only
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, alert: "Try again later." }

  def show
    @user = User.new
  end

  def create
    # Use service to create user in both primary and public databases
    @user = DatabaseUserService.create_user_with_database_access(sign_up_params)

    if @user&.persisted?
      start_new_session_for(@user)
      redirect_to root_path
    else
      @user ||= User.new(sign_up_params)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.expect(user: [ :name, :username, :email_address, :password, :password_confirmation ])
  end
end
