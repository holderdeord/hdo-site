module Api
  module RootRepresenter
    include Roar::Representer::JSON::HAL

    link(:self)            { api_root_url }
    link(:license)         { {href: "http://creativecommons.org/licenses/by-sa/3.0/no/", type: 'text/html'} }

    # hdo
    link(:issues)          { api_issues_url }

    # parliament
    link(:representatives) { api_representatives_url }
    link(:parties)         { api_parties_url }
    link(:committees)      { api_committees_url }
  end
end