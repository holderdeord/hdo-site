module ApiSpecHelper
  def json_response
    @json_response ||= JSON.parse(response.body)
  end

  def relations
    rels = json_response.fetch('_links').keys
    rels += json_response['_embedded'].keys if json_response.key?('_embedded')

    rels.sort
  rescue KeyError => ex
    raise KeyError, "#{ex.message} for #{json_response.inspect}"
  end
end
