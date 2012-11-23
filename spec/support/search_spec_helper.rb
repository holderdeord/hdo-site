module SearchSpecHelper
  def index
    described_class.index
  end

  def refresh_index
    index.refresh
  end

  def recreate_index
    index.delete

    opts = {
      mappings: described_class.tire.mapping_to_hash,
      settings: described_class.tire.settings
    }

    ok = index.create(opts)
    ok or raise "unable to create index for #{described_class}: #{index.response.body}"
  end

  def results_for(query)
    described_class.search(query).results
  end
end