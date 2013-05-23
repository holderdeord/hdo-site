class AdminController < ApplicationController
  include Hdo::Authorization
  layout 'logged_in'
  before_filter :authenticate_user!
end
