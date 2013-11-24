# encoding: UTF-8

class HomeController < ApplicationController
  hdo_caches_page :index,
                  :contact,
                  :support,
                  :people,
                  :about,
                  :member,
                  :robots,
                  :faq,
                  :friends,
                  :terms

  def index
    published = Issue.published.includes(:tags)

    @all_tags    = published.flat_map(&:tags).uniq.sort_by(&:name)
    @parties     = Party.order(:name)
    @issues      = published.for_frontpage(7).map { |e| e.decorate }
    @main_issue  = @issues.shift
    @questions   = Question.not_ours.with_approved_answers.order("answers.created_at").last(2).map(&:decorate)
    @leaderboard = Hdo::Stats::Leaderboard.new(published)
    @latest_posts = Hdo::Utils::BlogFetcher.last(2)
  end

  def robots
    if Rails.env.production?
      robots = ''
    else
      robots = "User-Agent: *\nDisallow: /\n"
    end

    render text: robots, layout: false, content_type: "text/plain"
  end

  def about
  end

  def faq
  end

  def contact
  end

  def support
  end

  def member
  end

  def friends
  end

  def revision
    rev = AppConfig['revision'] ||= (
      file = Rails.root.join('REVISION')
      file.exist? ? file.read : `git rev-parse HEAD`.strip
    )

    render text: rev, content_type: 'text/plain'
  end

  def healthz
    head :ok
  end

  def people
    @all_members = User.where(active: true).sort_by { |e| e.name.split(" ").last }
    @board = @all_members.select { |member| member.board? }

    @other = [
      "Alex Asensi",
      "Bjørn Dyresen",
      "Eli Foss",
      "Kristofer Rees",
      "Lotte Bredesen Simonsen",
      "Petter Reinholdsen",
      'Anders Berg Hansen',
      'Anne Raaum Christensen',
      'Carl Martin Rosenberg',
      'Cathrine Berg-Nielsen',
      'Cosimo Streppone',
      'Daniel Kafkas',
      'Dina Hestad',
      'Einar Kjerschow',
      'Einar Sundin',
      'Eirik Swensen',
      'Elida Høeg',
      'Ellen M. E. Lundring',
      'Endre Ottosen',
      'Erik Seierstad',
      'Esben Jensen',
      'Frode Hiorth',
      'Guro Øistensen',
      'Inge Olav Fure',
      'Ingrid Lomelde',
      'Ingrid Ødegaard',
      'Jan Olav Ryfetten',
      'Joanna Merker',
      'Jostein Holje',
      'Kristian Bysheim',
      'Kristiane Hammer',
      'Linda Myrvang',
      'Linn Katrine Erstad',
      'Liv Arntzen Løchen',
      'Madeleine Skjelland Eriksen',
      'Magnus Løseth',
      'Marit Sjøvaag Marino',
      'Markus Krüger',
      'Marte Haabeth Grindaker',
      'Martin Bekkelund',
      'Nina Jensen',
      'Ole Martin Volle',
      'Osman Siddique',
      'Rigmor Haga',
      'Salve Nilsen',
      'Sara Mjelva',
      'Silje Nyløkken',
      'Svein Halvor Halvorsen',
      'Tage Augustson',
      'Thomas Huang',
      'Tommy Steinsli',
      'Tor Håkon Inderberg',
      'Vegar Heir',
      'Vilde Grønn',
      'Øystein Jerkø Kostøl',
     ]
  end
end
