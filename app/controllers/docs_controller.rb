class DocsController < ApplicationController
  def index
    @import_types = [
      Hdo::Import::Party,
      Hdo::Import::Committee,
      Hdo::Import::District,
      Hdo::Import::Representative,
      Hdo::Import::Topic,
      Hdo::Import::Issue,
    ]
  end
end
