class Settings::DatabaseAccessesController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user
  end

  def reveal_password
    @user = Current.user

    unless @user.has_database_credentials?
      redirect_to settings_database_access_path, alert: "Database access not set up."
      nil
    end
  end

  def verify_password
    @user = Current.user

    unless @user.has_database_credentials?
      redirect_to settings_database_access_path, alert: "Database access not set up."
      return
    end

    if @user.authenticate(params[:password])
      @database_password = @user.database_password
      @password_revealed = true
      render :reveal_password
    else
      flash.now[:alert] = "Invalid password."
      render :reveal_password
    end
  end
end
