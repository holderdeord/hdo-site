class DocsController < ApplicationController
  def index
    @import_types = [
      Hdo::Import::Representative,
      Hdo::Import::Party,
      Hdo::Import::Issue,
      Hdo::Import::Topic,
      Hdo::Import::Committee,
    ]
  end
end
