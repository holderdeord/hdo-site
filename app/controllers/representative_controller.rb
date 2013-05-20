class RepresentativeController < ApplicationController
  layout 'logged_in'
  before_filter :authenticate_representative!
end