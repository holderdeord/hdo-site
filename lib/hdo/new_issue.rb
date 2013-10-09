# encoding: utf-8

require 'forwardable'

module Hdo
  class NewIssue
    extend Forwardable

    def_delegators :@issue, :title,
                           :description,
                           :updated_at,
                           :tags


    def self.from_issue(issue)
      new(issue)
    end

    def initialize(issue)
      @issue = issue
    end

    def explanation
      vcs = vote_connections

      count = vcs.size
      start_date = vcs.last.time
      end_date = vcs.first.time

      "#{count} avstemninger på Stortinget mellom #{start_date} og #{end_date}"
    end

    def vote_connections
      @issue.vote_connections.sort_by { |e| e.vote.time }.reverse
    end

    def periods
      periods = @issue.vote_connections.map { |e| e.vote.parliament_period }.uniq

      periods.map do |period|
        OpenStruct.new(name: period.name, events: [
          OpenStruct.new(name: "Event 1"),
          OpenStruct.new(name: "Event 2"),
          OpenStruct.new(name: "Event 3"),
        ], positions: [
          OpenStruct.new(title: "Bygge flere"),
          OpenStruct.new(title: "Bygge færre")
        ])
      end
    end

  end
end
