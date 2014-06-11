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
      img = @party.logo.versions[version.to_sym]

      if img
        redirect_to img.url
      else
        head status: 404
      end
    end

    def representatives
      rel = @party.representatives.includes(:district, party_memberships: :party, committee_memberships: :committee)
      rel = rel.attending if params[:attending]
      rel = rel.page(params[:page] || 1)

      respond_with rel, represent_with: RepresentativesRepresenter, attending: params[:attending], party: @party
    end

    private

    def fetch_party
      @party = Party.find(params[:id])
    end

  end
end
