class RepresentativeController < ApplicationController
  layout 'representative'
  before_filter :authenticate_representative!
end