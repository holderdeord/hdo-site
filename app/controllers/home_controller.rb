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
                  :statutes,
                  :opensearch

  skip_before_filter :force_ssl_redirect, only: :healthz

  def index
    @parties      = Party.order(:name)

    @latest_posts = Hdo::Utils::BlogFetcher.last(AppConfig.blog_count)

    propositions = Proposition.published.interesting.order('created_at DESC').first(10)
    @propositions_feed = Hdo::Utils::PropositionsFeed.new(propositions, see_all: true, show_parties: AppConfig.parties_in_proposition_feed)
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

  def opensearch
    render layout: false, content_type: 'application/opensearchdescription+xml'
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
    @all_members, non_active = User.all.sort_by { |e| e.name.split(" ").last }.partition(&:active?)
    @board = @all_members.select { |member| member.board? }
    @other = (non_active.map(&:name) + ALUMNI).uniq.sort_by { |name| name.split(" ").last }
  end

  ALUMNI = [
    "Tage Augustson",
    "Martin Bekkelund",
    "Cathrine Berg-Nielsen",
    "Kristian Bysheim",
    "Anne Raaum Christensen",
    "Madeleine Skjelland Eriksen",
    "Linn Katrine Erstad",
    "Inge Olav Fure",
    "Marte Haabeth Grindaker",
    "Vilde Grønn",
    "Rigmor Haga",
    "Svein Halvor Halvorsen",
    "Kristiane Hammer",
    "Anders Berg Hansen",
    "Vegar Heir",
    "Dina Hestad",
    "Frode Hiorth",
    "Jostein Holje",
    "Thomas Huang",
    "Elida Høeg",
    "Tor Håkon Inderberg",
    "Nina Jensen",
    "Esben Jensen",
    "Einar Kjerschow",
    "Øystein Jerkø Kostøl",
    "Ingrid Lomelde",
    "Ellen M. E. Lundring",
    "Liv Arntzen Løchen",
    "Magnus Løseth",
    "Marit Sjøvaag Marino",
    "Joanna Merker",
    "Linda Myrvang",
    "Salve Nilsen",
    "Silje Nyløkken",
    "Endre Ottosen",
    "Carl Martin Rosenberg",
    "Jan Olav Ryfetten",
    "Erik Seierstad",
    "Osman Siddique",
    "Tommy Steinsli",
    "Cosimo Streppone",
    "Einar Sundin",
    "Eirik Swensen",
    "Ole Martin Volle"
  ]
end
