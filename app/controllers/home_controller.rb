# encoding: UTF-8

class HomeController < ApplicationController
  caches_page :index, :if => lambda { flash.empty? && !user_signed_in? }
  caches_page :press, :join, :support, :people, :about_method, :member

  def index
    @topic_columns = Topic.column_groups
    @parties = Party.order(:name)
  end

  def about
    if params[:lang] == "en"
      render :about, :locale => "en"
    end
  end

  # don't override Object#method
  def about_method
  end

  def press
  end

  def login_status
    render layout: false
  end

  def join
  end

  def support
  end

  def member
  end

  def people
    @board = [
      Person.new('Jari Bakken', 'jari@holderdeord.no', 'arbeider med utvikling i Holder de ord. Han jobber til daglig hos FINN.no, hovedsakelig med interne verktøy og testautomasjon. Jari programmerer for det meste i Ruby og JavaScript, og står bak <a href="http://github.com/jarib">mange populære open source-prosjekt</a> med flere millioner nedlastinger. Han er selvlært som utvikler, og har en bachelor i utøvende jazzgitar fra Norges Musikkhøgskole.'),
      Person.new('Eva Jørgensen', nil, 'tar en mastergrad i politisk økonomi ved Handelshøyskolen BI og skriver sin masteroppgave om lobbyvirksomhet i EU. Hun har to bachelorgrader: en i Europastudier fra Universitetet i Oslo, og en i økonomi og administrasjon fra Høyskolen i Oslo. I Holder de ord jobber hun med nettverksbygging og finansiering.'),
      Person.new('Morten Kjelkenes', nil, '(NUUG) er teknisk ansvarlig og arkitekt. Morten jobber til daglig med prosjektledelse av både telecom- og IT-prosjekter, og har god teknisk erfaring innen konsolidering og virtualisering av tjenester for store kunder. Han har lang erfaring med kompliserte og heterogene miljøer og tjenester, samt fra oppbygging av testmiljøer for disse.'),
      Person.new('Daniel Rees', 'daniel@holderdeord.no', 'er daglig leder og en av grunnleggerne av Holder de ord. Han har en mastergrad i statsvitenskap fra NTNU i Trondheim, og har bakgrunn fra TNS Gallup hvor han har jobbet med opinionsundersøkelser og kommunikasjonsanalyse. Daniel har bred erfaring som frilansjournalist, fra NRK Her & Nå, og har tidligere jobbet med å utvikle nettsteder for FNs informasjonskontor for Norden og landsdekkende organisasjoner i Norge.'),
      Person.new('Kristofer Rees', 'kristofer@holderdeord.no', ' jobber med metode, faglig innhold og kategorisering av politiske løfter for Holder De Ord. Kristofer har tidligere studert musikk ved NTNU i Trondheim og Det Kgl. Danske Musikkonservatorium i København, og studerer nå statsvitenskap ved Universitetet i Oslo.'),
      Person.new('Tiina Ruohonen', 'tiina@holderdeord.no', 'er en av grunnleggerne av Holder de ord. I dag sitter hun i Holder de ords styre, og har det overordnede ansvaret for kommunikasjon, samfunnskontakt og medierelasjoner. Hun er en selverklært kosmopolitt med fartstid fra flere land, og med en mastergrad i bærekraftig utvikling og etikk. Tiina jobbet i flere år som prosjektleder innenfor klimaområdet, og driver i dag sitt eget konsulentselskap innenfor klima og miljø, etikk, samfunnsansvar, og demokratisk medvirkning.'),
      Person.new('Linn Skorge', 'linn@holderdeord.no', 'jobber med salg og finansiering i Holder de ord. Linn tar for øyeblikket en mastergrad i politisk økonomi på Handelshøyskolen BI. Fra tidligere har hun en bachelorgrad i internasjonal markedsføring, også fra Handelshøyskolen BI.'),
      Person.new('Guro Øistensen', nil, 'jobber med metode og det faglige innholdet i Holder de ord. Til daglig er hun Communications Manager i IT-bedriften Logica, hvor hun jobber med internett, intranett, PR og intern kommunikasjon. Guro er utdannet sosiolog fra Universitetet i Oslo.')
    ]

    @contributors = [
      Person.new('Kat Aquino'),
      Person.new('Martin Bekkelund'),
      Person.new('Anders Berg Hansen'),
      Person.new('Cathrine Berg-Nielsen'),
      Person.new('Kristian Bysheim'),
      Person.new('Linn Katrine Erstad'),
      Person.new('Inge Olav Fure'),
      Person.new('Arne Hassel'),
      Person.new('Svein Halvor Halvorsen'),
      Person.new('Jostein Holje'),
      Person.new('Vegard Karevoll'),
      Person.new('Markus Krüger'),
      Person.new('Joanna Merker'),
      Person.new('Sara Mjelva'),
      Person.new('Salve J. Nilsen'),
      Person.new('Gustav Oddsson'),
      Person.new('Endre Ottosen'),
      Person.new('Petter Reinholdtsen'),
      Person.new('Jonathan Ronen'),
      Person.new('Carl Martin Rosenberg'),
      Person.new('Erik Seierstad'),
      Person.new('Osman Siddique'),
      Person.new('Cosimo Streppone'),
      Person.new('Hanna Welde Tranås'),
      Person.new('Ingrid Ødegaard')
    ]

    @alumni = [
      Person.new('Tage Augustson'),
      Person.new('Anne Raaum Christensen'),
      Person.new('Marte Haabeth Grindaker'),
      Person.new('Vilde Grønn'),
      Person.new('Rigmor Haga'),
      Person.new('Vegar Heir'),
      Person.new('Dina Hestad'),
      Person.new('Thomas Huang'),
      Person.new('Elida Høeg'),
      Person.new('Tor Håkon Inderberg'),
      Person.new('Esben Jensen'),
      Person.new('Nina Jensen'),
      Person.new('Einar Kjerschow'),
      Person.new('Øystein Jerkø Kostøl'),
      Person.new('Ingrid Lomelde'),
      Person.new('Ellen M. E. Lundring'),
      Person.new('Liv Arntzen Løchen'),
      Person.new('Magnus Løseth'),
      Person.new('Marit Sjøvaag Marino'),
      Person.new('Tommy Steinsli'),
      Person.new('Einar Sundin'),
      Person.new('Eirik Swensen')
     ]
  end

  class Person
    attr_reader :name, :email, :bio

    def initialize(name, email = nil, bio = nil)
      @name, @email, @bio = name, email, bio
    end
  end

end
