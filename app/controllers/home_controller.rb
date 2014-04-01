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
                  :terms,
                  :statutes

  def index
    published = Issue.published.includes(:tags)

    @all_tags     = published.flat_map(&:tags).uniq.sort_by(&:name)
    @parties      = Party.order(:name)
    @issues       = published.for_frontpage(5).map(&:decorate)
    @main_issue   = @issues.shift
    @leaderboard  = Hdo::Stats::Leaderboard.new(published, ParliamentPeriod.named('2009-2013'))
    @latest_posts = Hdo::Utils::BlogFetcher.last(2)

    propositions = Proposition.published.interesting.order('created_at DESC').first(6)
    @propositions_feed = Hdo::Utils::PropositionsFeed.new(propositions, :see_all => true)
  end

  def robots
    path = Rails.root.join("config/robots/#{Rails.env}.txt")

    render text: path.exist? ? path.read : '', layout: false, content_type: 'text/plain'
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

    render text: rev, layout: false, content_type: 'text/plain'
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
