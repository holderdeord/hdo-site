class DocsController < ApplicationController
  def index
    # TODO: split into "main" and "sub" types

    @import_types = [
      Hdo::Import::Party,
      Hdo::Import::Committee,
      Hdo::Import::District,
      Hdo::Import::Representative,
      Hdo::Import::Category,
      Hdo::Import::Issue,
      Hdo::Import::Vote,
      Hdo::Import::Proposition,
      Hdo::Import::Promise,
    ]
  end
end
