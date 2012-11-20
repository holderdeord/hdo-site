module SearchSpecHelper
  def index
    described_class.index
  end

  def refresh_index
    index.refresh
  end

  def recreate_index
    index.delete
    index.create mappings: described_class.tire.mapping_to_hash,
                 settings: described_class.tire.settings

  end
end