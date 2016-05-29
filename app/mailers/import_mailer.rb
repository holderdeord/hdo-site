class ImportMailer < ActionMailer::Base
  layout 'hdo_mail'

  default from: 'Import <kontakt@holderdeord.no>',
          to:   'Intern <intern@holderdeord.no>'

  def votes_today_email
    votes = Vote.since_yesterday
    @upcoming_issues = ParliamentIssue.since_yesterday.upcoming

    if votes.empty? && @upcoming_issues.empty?
      return
    end

    @parliament_issues = votes.flat_map { |vote| vote.parliament_issues.to_a }.uniq

    counts = Hash.new(0)

    if @parliament_issues.any?
      counts['behandlet'] = @parliament_issues.size
    end

    @upcoming_issues.each do |pi|
      counts[pi.status_name.downcase] += 1
    end

    @subject = "Nye saker fra Stortinget: " + counts.map { |key, value| "#{value} #{key}" if value > 0 }.compact.join(', ')

    @rebel_tweets = Hdo::Utils::RebelTweeter.since(1.day.ago).to_a

    mail subject: @subject
  end
end
