module Api
  module RootRepresenter
    include Roar::Representer::JSON::HAL

    link(:self)            { api_root_url }
    link(:representatives) { api_representatives_url }
    link(:parties)         { api_parties_url }
    link(:issues)          { api_issues_url }
  end
end