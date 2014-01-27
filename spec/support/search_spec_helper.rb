module SearchSpecHelper
  def elasticsearch
    described_class.__elasticsearch__
  end

  def refresh_index
    elasticsearch.refresh_index!
  end

  def recreate_index
    elasticsearch.delete_index! force: true

    ok = elasticsearch.create_index!['ok']
    ok or raise "unable to create index for #{described_class}: #{index.response && index.response.body}"
  end

  def results_for(query)
    described_class.search(query).results
  end
end