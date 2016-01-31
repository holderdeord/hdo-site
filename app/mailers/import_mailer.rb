class ImportMailer < ActionMailer::Base
  layout 'hdo_mail'

  default from: 'Import <kontakt@holderdeord.no>',
          to:   'Intern <intern@holderdeord.no>'

  def votes_today_email
    votes = Vote.since_yesterday
    return unless votes.any?

    @parliament_issues = votes.flat_map { |vote| vote.parliament_issues.to_a }.uniq
    @rebel_tweets      = Hdo::Utils::RebelTweeter.since(1.day.ago).to_a
    @upcoming_issues   = ParliamentIssue.since_yesterday.upcoming

    mail subject: "#{@parliament_issues.size} nye saker behandlet"
  end
end
