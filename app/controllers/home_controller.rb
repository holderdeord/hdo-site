# encoding: UTF-8

class HomeController < ApplicationController
  caches_page :index, :contact, :join, :support, :people,
              :about_method, :member, :future, :robots,
              if: lambda { flash.empty? }

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
    @board = [
      Person.new('Jari Bakken', 'jari@holderdeord.no', 'hdo/jari.jpg', 'er sjefsutvikler i Holder de ord. Han jobber til daglig hos FINN.no, hovedsakelig med interne verktøy og testautomasjon. Jari programmerer for det meste i Ruby og JavaScript, og står bak <a href="http://github.com/jarib">mange populære open source-prosjekt</a> med flere millioner nedlastinger. Han er selvlært som utvikler. Jari sitter også i Holder de ords styre.'),
      Person.new('Eva Jørgensen', nil, 'hdo/eva-cecilie.jpg', 'jobber med regnskap og økonomistyring i Holder de ord. Hun har en mastergrad i politisk økonomi fra BI i Oslo. Eva har også to bachelorgrader: en i Europastudier fra Universitetet i Oslo, og en i økonomi og administrasjon fra Høyskolen i Oslo. Eva sitter også i Holder de ords styre.'),
      Person.new('Morten Kjelkenes', nil, 'hdo/morten.jpg', 'sitter i Holder de ords styre. Morten jobber til daglig med prosjektledelse av både telecom- og IT-prosjekter, og har god teknisk erfaring innen konsolidering og virtualisering av tjenester for store kunder. Han har lang erfaring med kompliserte og heterogene miljøer og tjenester, samt fra oppbygging av testmiljøer for disse.'),
      Person.new('Daniel Rees', 'daniel@holderdeord.no', 'hdo/daniel.jpg', 'er daglig leder og en av grunnleggerne av Holder de ord. Han har en mastergrad i statsvitenskap fra NTNU i Trondheim, og har bakgrunn fra TNS Gallup hvor han har jobbet med opinionsundersøkelser og kommunikasjonsanalyse. Daniel har bred erfaring som frilansjournalist og har tidligere jobbet med å utvikle nettsteder for FN og landsdekkende organisasjoner i Norge. Daniel er også styreleder i Holder de ord.'),
      Person.new('Kristofer Rees', 'kristofer@holderdeord.no', 'hdo/kristofer.jpg', 'er sjef for metode og analyse i Holder de ord. Han har en bachelorgrad i statsvitenskap, og har tidligere studert musikk ved NTNU i Trondheim og Det Kgl. Danske Musikkonservatorium i København. Kristofer sitter også i Holder de ords styre.'),
      Person.new('Tiina Ruohonen', 'tiina@holderdeord.no', 'hdo/tiina.jpg', 'er en av grunnleggerne av Holder de ord, nestleder og sjef for kommunikasjon, presse, og partnerskap. Tiina har en Cand. Mag. i statsvitenskap og juss, og en mastergrad i bærekraftig utvikling og etikk. Hun jobbet i flere år som prosjektleder og rådgiver på klimaområdet, og driver i dag sitt eget selskap som hjelper kunder med utfordringer innenfor klimaspørsmål, etikk, samfunnsansvar, og demokratisk medvirkning. Tiina sitter også i Holder de ords styre.'),
      Person.new('Linn Skorge', 'linn@holderdeord.no',  'hdo/linn.jpg', 'jobber med salg og finansiering i Holder de ord. Linn tar for øyeblikket en mastergrad i politisk økonomi på BI i Oslo. Fra tidligere har hun en bachelorgrad i internasjonal markedsføring, også fra Handelshøyskolen BI. Linn sitter også i Holder de ords styre.'),
      Person.new('Hanna Welde Tranås', 'hanna@holderdeord.no', 'hdo/hanna.jpg', 'leder det politiske analysearbeidet i Holder de ord. Hun er utdannet statsviter fra Universitetet i Oslo. Fra NTNU har hun en bachelorgrad i statsvitenskap og utviklingsstudier, samt et årsstudium i historie.'),
    ]

    @contributors = [
      Person.new('Alex Asensi'),
      Person.new('Kat Aquino'),
      Person.new('Bjørn Dyresen'),
      Person.new('Eli Foss'),
      Person.new('Inge Olav Fure'),
      Person.new('Arne Hassel'),
      Person.new('Henrik Helmers'),
      Person.new('Frode Hiorth'),
      Person.new('Jostein Holje'),
      Person.new('Simen Jensen'),
      Person.new('Vegard Karevold'),
      Person.new('Markus Krüger'),
      Person.new('Linda Therese Myrvang'),
      Person.new('Salve J. Nilsen'),
      Person.new('Knut Jørgen Rishaug'),
      Person.new('Gregers Skram Rygg'),
      Person.new('Petter Reinholdtsen'),
      Person.new('Tor Halle Rise'),
      Person.new('Jonathan Ronen'),
      Person.new('Jan Olav Ryfetten'),
      Person.new('Ingrid Ødegaard')
    ]

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
