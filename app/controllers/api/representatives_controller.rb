module Api
  class RepresentativesController < ApiController
    before_filter :fetch_representative, except: :index

    def index
      respond_with Representative.
                    order(:last_name).
                    page(params[:page] || 1).
                    per(10)
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
        render hal: {
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
