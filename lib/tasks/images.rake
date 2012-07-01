require 'net/http'
require 'uri'

namespace :images do
  task :fetch_representatives => :environment do
    Representative.all.map { |e| e.external_id }.each do |id|
      url = URI.parse("http://stortinget.no/Personimages/PersonImages_ExtraLarge/#{URI.escape id}_ekstrastort.jpg")
      
      File.open(File.join("app/assets/images/representatives", "#{id}.jpg"), "wb") do |destination|
        resp = Net::HTTP.get_response(url) do |response|
          total = response.content_length
          progress = 0
          segment_count = 0

          response.read_body do |segment|
            progress += segment.length
            segment_count += 1

            if segment_count % 15 == 0
              percent = (progress.to_f / total.to_f) * 100
              print "\rDownloading #{url}: #{percent.to_i}% (#{progress} / #{total})"
              $stdout.flush
              segment_count = 0
            end

            destination.write(segment)
          end
        end

        unless resp.kind_of? Net::HTTPSuccess
          puts "\nERROR:#{resp.code} for #{url}"
        end
      end
    end
  end
end