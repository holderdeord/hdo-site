# encoding: utf-8

namespace :promises do
  task :import => :environment do
    unless file = ENV['csv']
      raise "must pass csv=/path/to/promises.csv"
    end
    
    require 'csv'
    str = File.read(File.expand_path(file), encoding: "ISO-8859-1").encode("UTF-8")
    table = CSV.parse(
      str, 
      headers: [:party, :body, :general, :topics, :source, :page], 
      col_sep: ";",
      skip_blanks: true,
      return_headers: false
    )
    
    table.map do |e|
      data = e.to_hash
      next if data[:body] == "Løftetekst" || data[:body].nil? || data[:body].empty?
      
      party   = Party.find_by_external_id!(data[:party])
      general = data[:general].downcase.strip == "ja"
      topics  = Topic.where(:name => data[:topics].split(",").map(&:upcase).map(&:strip))
      source  = [data[:source], data[:page]].join(":")
      body    = data[:body]
      
      Promise.create!(:party => party, :general => general, :topics => topics, :source => source, :body => body)
      print '.'
    end
    
  end
end