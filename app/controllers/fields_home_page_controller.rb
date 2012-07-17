class FieldsHomePageController < ApplicationController
  before_filter :authenticate_user!
  def view
    render "/home/fields_home_page"
  end
end
