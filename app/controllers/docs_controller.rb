class DocsController < ApplicationController
  caches_page :index

  def index
    @representative_example = "<representatives>\n  " + Hdo::StortingImporter::Representative.xml_example.split("\n").join("\n  ") + "\n</representatives>"

    @import_types = [
      Hdo::StortingImporter::Party,
      Hdo::StortingImporter::Committee,
      Hdo::StortingImporter::District,
      Hdo::StortingImporter::Representative,
      Hdo::StortingImporter::Category,
      Hdo::StortingImporter::Issue,
      Hdo::StortingImporter::Vote,
      Hdo::StortingImporter::Vote::Proposition,
      Hdo::StortingImporter::Promise,
    ]
  end
end
