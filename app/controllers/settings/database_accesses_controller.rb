class Settings::DatabaseAccessesController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user
  end

  # TODO: add validation for special characters in username/password
  # TODO: enforce password complexity requirements
  def new
    # Show database access setup form for user to fill in their desired credentials
    @user = Current.user

    # Redirect if user already has credentials
    if @user.has_database_credentials?
      redirect_to settings_database_access_path, notice: "Database access is already set up. You can view your credentials below."
    end
  end

  def create
    @user = Current.user
    username = params[:database_username]
    password = params[:database_password]

    # Validate that credentials were provided
    if username.blank? || password.blank?
      flash[:alert] = "Both username and password are required."
      render :new and return
    end

    # Check if username is already taken by another user
    existing_user = User.where(database_username: username).where.not(id: @user.id).first
    if existing_user.present?
      flash[:alert] = "Username '#{username}' is already taken. Please choose a different username."
      render :new and return
    end

    # check username in public database before kicking off bg job
    # NEW: Check if username exists in PostgreSQL public database
    if AactPublic::DatabaseUser.user_exists?(username)
      flash[:alert] = "Username '#{username}' is already taken in database. Please choose a different username."
      render :new and return
    end

    # Store credentials (password encrypted, username plain text for uniqueness checks)
    @user.database_username = username
    @user.database_password = password
    @user.database_creation_status = "pending"
    @user.database_creation_attempted_at = Time.current

    if @user.save
      # Enqueue background job to create the database user
      CreateDatabaseUserJob.perform_later(@user.id)

      # This automatically responds with turbo_stream format
      # Rails looks for show.turbo_stream.erb first, falls back to show.html.erb
      render :show
    else
      # Validation errors (e.g., username uniqueness)
      flash[:alert] = @user.errors.full_messages.join(", ")
      render :new
    end
  end

  def reveal_password
    @user = Current.user

    unless @user.has_database_credentials?
      redirect_to settings_database_access_path, alert: "Database access not set up."
      nil
    end
  end

  def verify_account_password
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
