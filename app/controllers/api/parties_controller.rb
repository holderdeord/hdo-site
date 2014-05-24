module Api
  class PartiesController < ApiController
    before_filter :fetch_party, except: :index


    def index
      respond_with Party.order(:name).page(params[:page] || 1)
    end

    def show
      respond_with @party
    end

    def logo
      version = params[:version] || :medium
      img = @party.image.versions[version.to_sym]

      if img
        redirect_to img.url
      else
        head status: 404
      end
    end

    private

    def fetch_party
      @party = Party.find(params[:id])
    end

  end
end
