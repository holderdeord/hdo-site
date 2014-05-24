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
      img = @representative.image.versions[version.to_sym]

      if img
        redirect_to img.url
      else
        render status: 404
      end
    end

    private

    def fetch_representative
      @representative = Representative.find(params[:id])
    end
  end
end
