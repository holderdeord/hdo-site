class SearchController < ApplicationController
  INDECES = {
    'issues'            => { boost: 5   },
    'parties'           => { boost: 3.5 },
    'representatives'   => { boost: 2   },
    'promises'          => { boost: 1   },
    'propositions'      => { boost: 1   },
    'parliament_issues' => { boost: 1   },
    'topics'            => { boost: 2   },
  }

  def all
    @query = params[:query]

    search = Tire.search(INDECES) do |s|
      s.size 25

      s.query do |query|
        query.string @query
      end

      s.sort { by :_score }
    end

    logger.info search.to_curl
    @results = search.results

    respond_to do |format|
      format.json { render json: @results }
      format.html { render layout: params[:layout] }
    end
  end
end
