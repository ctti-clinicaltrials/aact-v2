class Admin::UsersController < Admin::BaseController
  def index
    scope = User
      .search(search_param)
      .order(created_at: :desc)

    @pagy, @users = pagy(scope, limit: 20)

    render :results if turbo_frame_request?
  end

  def show
    @user = User.find(params[:id])

    if @user.database_username.present?
      @days_active, @first_active, @last_active = AactPublicQueryMetric
        .where(username: @user.database_username)
        .pick(Arel.sql("COUNT(*), MIN(log_date), MAX(log_date)"))
    end
  end

  def download_csv
    scope = User
      .search(search_param)
      .order(created_at: :desc)

    users = scope.limit(10_000)
    csv_data = generate_csv(users)

    send_data csv_data,
              filename: "aact_users_#{Time.current.strftime('%Y%m%d')}.csv",
              type: "text/csv"
  end

  private

  def search_param
    params[:search]&.strip&.slice(0, 100)
  end

  def generate_csv(users)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << %w[Name Email DB_Username Admin DB_Status Joined Migrated]
      users.each do |user|
        csv << [
          user.name,
          user.email_address,
          user.database_username,
          user.admin?,
          user.database_creation_status,
          user.created_at&.strftime("%Y-%m-%d"),
          user.migrated?
        ]
      end
    end
  end
end
