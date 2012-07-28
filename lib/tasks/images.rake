require 'net/http'
require 'uri'

namespace :images do
  desc 'Fetch representatives images from stortinget.no'
  task :fetch_representatives => :environment do
    rep_image_path = File.join(Rails.root, "app/assets/images/representatives")
    generic_image_filename = File.join(rep_image_path, "unknown.jpg")

    Representative.all.each do |rep|
      url = URI.parse("http://stortinget.no/Personimages/PersonImages_ExtraLarge/#{URI.escape rep.external_id}_ekstrastort.jpg")

      filename = File.join(rep_image_path, "#{rep.slug}.jpg")

      File.open(filename, "wb") do |destination|
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

        destination.close

        if !resp.kind_of?(Net::HTTPSuccess)
          puts "\nERROR:#{resp.code} for #{url}"
          File.delete(destination.path)
        else
          if File.zero?(destination.path)
            puts "\nERROR: url #{url} returned an empty file"
            File.delete(destination.path)
          else
            print "\rDownloading #{url} finished. Saved as #{filename}\n"
            $stdout.flush
            rep.image = Pathname.new filename
          end
        end

        rep.save!
      end
    end
  end
end

