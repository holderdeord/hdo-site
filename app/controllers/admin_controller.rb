class AdminController < ApplicationController
  layout 'logged_in'
  before_filter :authenticate_user!
end
