module Api
  class RepresentativesController < ApiController
    before_filter :fetch_representative, except: :index

    def index
      representatives = Representative.
                          includes(:committees, party_memberships: :party).
                          order(:last_name)



      if params[:attending]
        representatives = representatives.attending
      end

      respond_with representatives.page(params[:page] || 1).per(params[:size] || 10)
    end

    def show
      respond_with @representative
    end

    def image
      version = params[:version] || :medium

      images = @representative.image
      image = images.versions[version.to_sym]

      if image
        redirect_to image.url
      else
        render json: {
          message: "invalid version #{version.inspect}, expected #{images.versions.keys.inspect}"
        }, status: :bad_request
      end
    end

    private

    def fetch_representative
      @representative = Representative.find(params[:id])
    end
  end
end
