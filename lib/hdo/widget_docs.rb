# encoding: utf-8

module Hdo
  class WidgetDocs
    def specific_issue(issue)
      Widget.new(
        'Sak',
        'utvalgt sak',
        "<a class='hdo-issue-widget' href='#{root_url}' data-issue-id='#{issue.try(:id)}'>Laster innhold fra Holder de ord</a>",
        "<iframe src='#{widget_issue_url(issue)}'>"
      )
    end

    def party_default(party)
      Widget.new(
        'Parti',
        'siste 5 saker etter voteringstidspunkt',
        "<a class='hdo-party-widget' href='#{root_url}' data-party-id='#{party.try(:id)}'>Laster innhold fra Holder de ord</a>",
        "<iframe src='#{widget_party_url(party)}'>"
      )
    end

    def party_count(party, n)
      Widget.new(
        'Parti',
        "siste N=#{n} saker etter voteringstidspunkt",
        "<a class='hdo-party-widget' href='#{root_url}' data-count='#{n}' data-party-id='#{party.try(:id)}'>Laster innhold fra Holder de ord</a>",
        "<iframe src='#{widget_party_url(party, count: n)}'>"
      )
    end

    def party_issues(party, issues)
      ids = issues.map(&:id).join(",")

      Widget.new(
        'Parti',
        'utvalgte saker',
        "<a class='hdo-party-widget' href='#{root_url}' data-issue-ids='#{ids}' data-party-id='#{party.try(:id)}'>Laster innhold fra Holder de ord</a>",
        "<iframe src='#{widget_party_url(party, issues: ids)}'>"
      )
    end

    def promises(promises)
      ids = promises.map(&:id).join(',')

      Widget.new(
        'Løfter',
        'utvalgte løfter',
        "<a class='hdo-promises-widget' href='#{root_url}' data-promises='#{ids}'>Laster innhold fra Holder de ord</a>",
        "<iframe src='#{widget_promises_url(promises: ids)}'>"
      )
    end

    class Widget < Struct.new(:title, :subtitle, :script, :iframe, :code)
    end

    include Rails.application.routes.url_helpers

    def default_url_options
      @default_url_options ||= {host: 'www.holderdeord.no'}.merge(Rails.application.config.action_mailer.default_url_options)
    end
  end
end
