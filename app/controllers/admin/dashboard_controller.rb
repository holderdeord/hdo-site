class Admin::DashboardController < AdminController
  def index
    @pending_questions           = Question.pending
    @questions_answer_pending    = Question.with_pending_answers

    published         = Issue.published
    proposition_count = Proposition.count
    promise_count     = Promise.count

    @issue_proposition_percentage = published.flat_map(&:proposition_ids).uniq.size * 100 / (proposition_count.zero? ? 1 : proposition_count)
    @issue_promise_percentage     = published.flat_map(&:promise_ids).uniq.size * 100 / (promise_count.zero? ? 1 : promise_count)
    @issue_user_percentage        = current_user.percentage_of_issues

    @proposition_histogram = fetch_proposition_counts
    @proposition_stats     = fetch_proposition_stats
  end

  private

  def fetch_proposition_counts
    labels = []
    data   = []

    result = {labels: labels, data: data}

    begin
      response = Hdo::Search::Searcher.new('*').proposition_histogram

      if response.success?
        entries = response.facets['counts']['entries']
        weeks = Hash.new(0)

        entries.each do |e|
          time  = Time.at(e['time'] / 1000).localtime
          week  = time.strftime("%W").to_i
          count = e['count']

          weeks[week] = count
        end

        this_week = Time.now.strftime("%W").to_i
        current_week = weeks.keys.first

        until current_week == (this_week + 1)
          labels << "Uke #{current_week}"
          data << weeks[current_week]

          current_week += 1
          current_week = 1 if current_week == 53
        end
      end

      result
    rescue => ex
      logger.error ex.message
      result
    end
  end

  def fetch_proposition_stats
    [ParliamentSession.current, ParliamentSession.previous].compact.map do |session|
      [session, Hdo::Stats::PropositionCounts.from_session(session.name)]
    end
  end

end
