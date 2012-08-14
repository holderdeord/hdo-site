class HomeController < ApplicationController
  caches_page :index, :unless => :user_signed_in?
  caches_page :press, :join, :support, :people, :about_method

  def index
    @field_columns = Field.column_groups
  end

  def about
    if params[:lang] == "en"
      render :about, :locale => "en"
    end
  end

  def press
  end

  def login_status
    render layout: false
  end

  def join
  end

  def support
  end

  def people
  end

  # don't override Object#method
  def about_method
  end
end
