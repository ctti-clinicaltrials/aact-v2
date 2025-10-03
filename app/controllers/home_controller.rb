class HomeController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  def index
    # This will be accessible to both authenticated and unauthenticated users
    # The view will conditionally show content based on authentication state
  end
end
