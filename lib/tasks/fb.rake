namespace :facebook do 
  task :issues => :environment do
    helpers = Rails.application.routes.url_helpers

    urls = Issue.published.map do |issue|
      helpers.issue_url(issue, host: 'www.holderdeord.no')
    end

    fql = 'SELECT url, total_count FROM link_stat WHERE url in (%s)'
    fql = fql  % urls.map(&:inspect).join(',')

    resp = Typhoeus.get "http://graph.facebook.com/fql?q=#{URI.escape fql}"

    if resp.code == 200
      data = JSON.parse(resp.body).fetch('data')
      data.sort_by { |e| e['']}
    else
      raise "Graph API response: #{resp.code} #{resp.body}"
    end

    interesting = data.reject { |e| e['total_count'].zero? }.sort_by { |e| e['total_count'] }

    interesting.each do |e| 
      puts [e['total_count'].to_s.ljust(3), e['url']].join 
    end
  end
end