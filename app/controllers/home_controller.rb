# encoding: UTF-8

class HomeController < ApplicationController
  hdo_caches_page :index, :contact, :join, :support, :people,
                  :about_method, :member, :future, :robots

  def index
    @issues  = Issue.published.random(6)
    @parties = Party.order(:name)
  end

  def about
    if params[:lang] == "en"
      render :about, :locale => "en"
    end
  end

  def robots
    if Rails.env.production?
      robots = ''
    else
      robots = "User-Agent: *\nDisallow: /\n"
    end

    render text: robots, layout: false, content_type: "text/plain"
  end

  # don't override Object#method
  def about_method
  end

  def contact
  end

  def join
  end

  def support
  end

  def member
  end

  def future
  end

  def revision
    rev = AppConfig['revision'] ||= (
      file = Rails.root.join('REVISION')
      file.exist? ? file.read : `git rev-parse HEAD`.strip
    )

    render :text => rev, content_type: 'text/plain'
  end

  def healthz
    head :ok
  end

  def people
    users = User.where(active: true)

    @board, @contributors = users.partition { |e| e.board? }

    @alumni = [
      Person.new('Tage Augustson'),
      Person.new('Martin Bekkelund'),
      Person.new('Anders Berg Hansen'),
      Person.new('Cathrine Berg-Nielsen'),
      Person.new('Kristian Bysheim'),
      Person.new('Anne Raaum Christensen'),
      Person.new('Madeleine Skjelland Eriksen'),
      Person.new('Linn Katrine Erstad'),
      Person.new('Marte Haabeth Grindaker'),
      Person.new('Vilde Grønn'),
      Person.new('Rigmor Haga'),
      Person.new('Svein Halvor Halvorsen'),
      Person.new('Kristiane Hammer'),
      Person.new('Vegar Heir'),
      Person.new('Dina Hestad'),
      Person.new('Thomas Huang'),
      Person.new('Elida Høeg'),
      Person.new('Tor Håkon Inderberg'),
      Person.new('Esben Jensen'),
      Person.new('Nina Jensen'),
      Person.new('Daniel Kafkas'),
      Person.new('Einar Kjerschow'),
      Person.new('Øystein Jerkø Kostøl'),
      Person.new('Ingrid Lomelde'),
      Person.new('Ellen M. E. Lundring'),
      Person.new('Liv Arntzen Løchen'),
      Person.new('Magnus Løseth'),
      Person.new('Carl Martin Rosenberg'),
      Person.new('Marit Sjøvaag Marino'),
      Person.new('Joanna Merker'),
      Person.new('Sara Mjelva'),
      Person.new('Silje Nyløkken'),
      Person.new('Endre Ottosen'),
      Person.new('Erik Seierstad'),
      Person.new('Osman Siddique'),
      Person.new('Tommy Steinsli'),
      Person.new('Cosimo Streppone'),
      Person.new('Einar Sundin'),
      Person.new('Eirik Swensen'),
      Person.new('Ole Martin Volle'),
      Person.new('Guro Øistensen')
     ]
  end

  class Person
    attr_reader :name, :image, :email, :bio

    def initialize(name, email = nil, image = nil, bio = nil)
      @name, @email, @image, @bio = name, email, image, bio
    end
  end

end
