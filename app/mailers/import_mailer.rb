class ImportMailer < ActionMailer::Base
  layout 'hdo_mail'

  default from: 'teknisk@holderdeord.no',
          to:   'analyse@holderdeord.no'

  def votes_today_email
    votes = Vote.since_yesterday
    return unless votes.any?

    @parliament_issues = votes.flat_map { |vote| vote.parliament_issues.to_a }.uniq

    mail subject: "#{@parliament_issues.size} nye saker behandlet"
  end
end
