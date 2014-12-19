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

  skip_before_filter :force_ssl_redirect, only: :healthz

  def index
    @parties      = Party.order(:name)

    @latest_posts = Hdo::Utils::BlogFetcher.last(AppConfig.blog_count)

    propositions = Proposition.published.interesting.order('created_at DESC').first(10)
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
      'Alex Asensi',
      'Anders Berg Hansen',
      'Anne Raaum Christensen',
      'Arne Hassel',
      'Bjørn Dyresen',
      'Carl Martin Rosenberg',
      'Cathrine Berg-Nielsen',
      'Cosimo Streppone',
      'Daniel Kafkas',
      'Daniel Rees',
      'Dina Hestad',
      'Einar Kjerschow',
      'Einar Sundin',
      'Eirik Swensen',
      'Eli Foss',
      'Elida Høeg',
      'Ellen M. E. Lundring',
      'Endre Ottosen',
      'Erik Seierstad',
      'Esben Jensen',
      'Frode Hiorth',
      'Guro Øistensen',
      'Hannah Granaas',
      'Inge Olav Fure',
      'Ingrid Lomelde',
      'Ingrid Ødegaard',
      'Jan Olav Ryfetten',
      'Joanna Merker',
      'Jostein Holje',
      'Kat Aquino',
      'Kristian Bysheim',
      'Kristiane Hammer',
      'Kristofer Rees',
      'Linda Myrvang',
      'Linn Katrine Erstad',
      'Liv Arntzen Løchen',
      'Lotte Bredesen Simonsen',
      'Madeleine Skjelland Eriksen',
      'Magnus Løseth',
      'Marit Sjøvaag Marino',
      'Markus Krüger',
      'Marte Haabeth Grindaker',
      'Martin Bekkelund',
      'Morten Kjelkenes',
      'Nina Jensen',
      'Ole Martin Volle',
      'Osman Siddique',
      'Petter Reinholdsen',
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
