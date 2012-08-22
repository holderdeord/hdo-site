namespace :cache do
  
  desc 'Temporary workaround for https://github.com/holderdeord/hdo-site/issues/183'
  task :promises do
    require 'restclient'
    require 'multi_json'
    require 'benchmark'
    
    root_url = ENV['ROOT_URL'] || 'http://beta.holderdeord.no'

    categories = MultiJson.decode RestClient.get("#{root_url}/categories.json")
    parties = MultiJson.decode RestClient.get("#{root_url}/parties.json")

    category_ids = categories.select { |e| e['main'] }.map { |e| e['id'] }
    party_slugs  = parties.map { |e| e['slug'] }
    
    Benchmark.bm do |results|
      category_ids.each do |cid|
        results.report("promises for #{cid}") { RestClient.head "#{root_url}/categories/#{cid}/promises" }
        
        party_slugs.each do |slug|
          results.report("promises for #{cid}/#{slug}:") { RestClient.head "#{root_url}/categories/#{cid}/promises/parties/#{slug}" }
        end
      end
    end
  end
end