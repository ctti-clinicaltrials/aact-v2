class Admin::BaseController < ApplicationController
  include Authorization
  admin_access_only
end
