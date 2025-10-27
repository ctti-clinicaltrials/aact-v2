class DatabaseAccessController < ApplicationController
  before_action :require_authentication

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

    # Store credentials (password encrypted, username plain text for uniqueness checks)
    @user.database_username = username
    @user.database_password = password

    if @user.save
      # Create the database user
      result = DatabaseUserService.create_database_user(
        username: username,
        password: password
      )

      if result[:success]
        @user.update!(database_user_created: true)
        redirect_to settings_database_access_path, notice: "Database access has been set up successfully!"
      else
        # Clear credentials if database user creation failed
        @user.update!(database_username: nil, database_password: nil)
        flash[:alert] = "Failed to set up database access: #{result[:error]}"
        render :new
      end
    else
      # Validation errors (e.g., username uniqueness)
      flash[:alert] = @user.errors.full_messages.join(", ")
      render :new
    end
  end
end
