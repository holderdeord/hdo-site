class DocsController < ApplicationController
  caches_page :index

  def index
    @representative_example = "[\n  " + Hdo::StortingImporter::Representative.json_example.split("\n").join("\n  ") + "\n]"

    @import_types = [
      Hdo::StortingImporter::Party,
      Hdo::StortingImporter::Committee,
      Hdo::StortingImporter::District,
      Hdo::StortingImporter::Representative,
      Hdo::StortingImporter::Category,
      Hdo::StortingImporter::Issue,
      Hdo::StortingImporter::Vote,
      Hdo::StortingImporter::Proposition,
      Hdo::StortingImporter::Promise,
    ]
  end
end
