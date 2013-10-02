# encoding: utf-8

require 'forwardable'

module Hdo
  class NewIssue
    extend Forwardable

    def_delegators :@data, :title,
                           :description,
                           :updated_at,
                           :tags


    def self.from_issue(issue)
      new DeepStruct.new(issue.as_json(
        include: [
           { :tags => {methods: :slug}},
           { :vote_connections    => {:include => {:vote => {methods: :stats}}}},
           { :promise_connections => {:include => {:promise => {:include => :parties}}}},
           { :valence_issue_explanations => {:include => :parties}}
        ]
      ))
    end

    def initialize(data = DeepStruct.load_issue)
      @data = data
      @issue = Issue.find(@data.id)
    end

    def explanation
      vcs = vote_connections

      count = vcs.size
      start_date = vcs.last.time
      end_date = vcs.first.time

      "#{count} avstemninger på Stortinget mellom #{start_date} og #{end_date}"
    end

    def vote_connections
      data.vote_connections.sort_by { |e| e.vote.time }.reverse.map { |vc| FakeVote.new(vc) }
    end

    def parties
      @parties ||= (
        party_names = data.vote_connections.flat_map { |e| e.vote.stats.as_json[:parties].keys }.uniq.map(&:to_s)
        party_names.sort.map do |pn|
          party = party_named(pn)
          valence_issue_explanation = data.valence_issue_explanations.find { |vie| vie.parties.map(&:name).include?(pn) }

          DeepStruct.new(
            'name'                => pn,
            'accountability_text' => issue.accountability.text_for(party, name: ''),
            'position_text'       => valence_issue_explanation.explanation,
            'position_title'      => valence_issue_explanation.title,
            'promises'            => data.promise_connections.select { |pc| pc.promise.parties.any? { |e| e.name == pn } }.map(&:promise),
            'small_logo'          => party.logo.versions[:small],
            'medium_logo'         => party.logo.versions[:medium],
          )
        end
      )
    end

    private

    attr_reader :data, :issue

    def party_named(name)
      Party.find_by_name!(name)
    end

    class FakeVote
      def initialize(conn)
        @conn = conn
      end

      def time
        I18n.l @conn.vote.time, format: :text
      end

      def title
        @conn.title
      end

      def enacted?
        @conn.vote.enacted
      end

      def comment
        @conn.comment
      end

      def parties_for
        @conn.vote.stats.as_json[:parties].select { |name, e| e[:for].to_i > e[:against].to_i }.map(&:first).sort
      end

      def parties_against
        @conn.vote.stats.as_json[:parties].select { |name, e| e[:for].to_i < e[:against].to_i }.map(&:first).sort
      end
    end

  end
end
