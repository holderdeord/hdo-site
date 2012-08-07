require 'net/http'
require 'uri'

namespace :images do
  desc 'Fetch representatives images from stortinget.no'
  task :fetch_representatives => :environment do
    rep_image_path = Rails.root.join("app/assets/images/representatives")

    Representative.all.each do |rep|
      url = URI.parse("http://stortinget.no/Personimages/PersonImages_ExtraLarge/#{URI.escape rep.external_id}_ekstrastort.jpg")

      filename = rep_image_path.join("#{rep.slug}.jpg")
      
      if ENV['FORCE'].nil? && filename.exist?
        puts "skipping download for existing #{filename}, use FORCE=true to override"
        rep.image = filename
        rep.save!
        next
      end

      File.open(filename.to_s, "wb") do |destination|
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

  desc 'Save party logos to Party models'
  task :save_party_logos => :environment do
    puts "Mapping each party's logo to image attribute"
    path_to_logos = Rails.root.join("app/assets/images/party_logos")

    Party.all.each do |party|
     party.image = Pathname.new("#{path_to_logos}/#{party.external_id}_logo_large.jpg")
     party.save!
     puts "Logo for #{party.name} mapped."
    end
  end

  task :all => %w[images:fetch_representatives images:save_party_logos]
end

