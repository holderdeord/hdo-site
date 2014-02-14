require 'net/http'
require 'uri'

namespace :images do
  namespace :representatives do
    desc 'Reset representative images'
    task :reset => :environment do
      Representative.all.each { |e| e.image = nil; e.save! }
    end

    desc 'Fetch representatives images from stortinget.no'
    task :fetch => :environment do
      rep_image_path = Rails.root.join("tmp/downloads/representatives")
      rep_image_path.mkpath

      Representative.all.each do |rep|
        url = URI.parse("https://stortinget.no/Personimages/PersonImages_ExtraLarge/#{URI.escape rep.external_id}_ekstrastort.jpg")

        filename = rep_image_path.join("#{rep.slug}.jpg")

        if ENV['FORCE'].nil? && filename.exist?
          puts "skipping download for existing #{filename}, use FORCE=true to override"

          rep.image = filename.open
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

              rep.image = filename.open
              rep.save!

              $stdout.flush
            end
          end
        end
      end
    end
  end

  desc 'Save and scale party logos to Party models'
  task :party_logos => :environment do
    path_to_logos = Rails.root.join("app/assets/images/party-logos-current")

    Party.all.each do |party|
      party.logo = path_to_logos.join("#{party.slug}.png").open
      party.save!
      puts "Logo for #{party.name} mapped as #{party.logo.url}."
    end
  end

  TOPICS = {
    'Samferdsel'      => {ids: [251, 149, 212, 161, 257, 193, 200, 166, 259, 77, 6], image: "tema_samferdsel.jpg"},
    'Utdanning'       => {ids: [48, 262, 263, 52, 99, 4, 53, 145, 278, 227, 141, 47, 65, 231], image: "tema_utdanning.jpg"},
    'Klima og energi' => {ids: [270, 268, 186, 191, 57, 80, 236, 264, 8, 250, 195, 252, 266], image: "tema_klima.jpg"},
    'Helse og omsorg' => {ids: [143,197,169,18,146,123,246,198,145,175,303,237], image: "tema_helse.jpg"}
  }

  task :update_topic_issues => :environment do
    topic_ids = TOPICS.fetch(AppConfig.topic_of_the_week).fetch(:ids)

    Issue.published.each do |issue|
      issue.frontpage = topic_ids.include?(issue.id)
      issue.save!
    end
  end

  desc 'Fetch topic image'
  task :topic => :environment do
    image = TOPICS.fetch(AppConfig.topic_of_the_week).fetch(:image)

    ok = system "curl", "-s", "-o", Rails.root.join('public/images/topic.jpg').to_s, "http://files.holderdeord.no/images/#{image}"
    ok or raise "topic download failed"
  end

  desc 'Set up all images'
  task :all => %w[images:representatives:fetch images:party_logos images:topic]

  desc 'Reset and set up all images'
  task :reset => %w[representatives:reset all]
end
