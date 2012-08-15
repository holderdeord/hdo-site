class DocsController < ApplicationController
  caches_page :index

  def index
    example = Hdo::StortingImporter::Representative.json_example.split("\n").join("\n  ")
    @representative_example = "[\n #{example} \n]"

    @import_types = [
      Hdo::StortingImporter::Party,
      Hdo::StortingImporter::Committee,
      Hdo::StortingImporter::District,
      Hdo::StortingImporter::Representative,
      Hdo::StortingImporter::Category,
      Hdo::StortingImporter::ParliamentIssue,
      Hdo::StortingImporter::Vote,
      Hdo::StortingImporter::Proposition,
      Hdo::StortingImporter::Promise,
    ]
  end
end
