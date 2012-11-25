# encoding: UTF-8

class HomeController < ApplicationController
  caches_page :index, if: lambda { flash.empty? && !user_signed_in? }
  caches_page :contact, :join, :support, :people, :about_method, :member, :future

  def index
    @issues        = Issue.published.random(6)
    @parties       = Party.order(:name)
  end

  def about
    if params[:lang] == "en"
      render :about, :locale => "en"
    end
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

  def people
    @board = [
      Person.new('Jari Bakken', 'jari@holderdeord.no', 'hdo/jari.jpg', 'er sjefsutvikler i Holder de ord. Han jobber til daglig hos FINN.no, hovedsakelig med interne verktøy og testautomasjon. Jari programmerer for det meste i Ruby og JavaScript, og står bak <a href="http://github.com/jarib">mange populære open source-prosjekt</a> med flere millioner nedlastinger. Han er selvlært som utvikler, og har en bachelor i utøvende jazzgitar fra Norges Musikkhøgskole.'),
      Person.new('Eva Jørgensen', nil, 'hdo/eva-cecilie.jpg', 'jobber med regnskap og økonomistyring i Holder de ord. Hun har en mastergrad i politisk økonomi fra BI i Oslo. Eva har også to bachelorgrader: en i Europastudier fra Universitetet i Oslo, og en i økonomi og administrasjon fra Høyskolen i Oslo. Eva sitter også i Holder de ords styre.'),
      Person.new('Morten Kjelkenes', nil, nil, 'er teknisk ansvarlig og driftssjef i Holder de ord. Morten jobber til daglig med prosjektledelse av både telecom- og IT-prosjekter, og har god teknisk erfaring innen konsolidering og virtualisering av tjenester for store kunder. Han har lang erfaring med kompliserte og heterogene miljøer og tjenester, samt fra oppbygging av testmiljøer for disse.'),
      Person.new('Daniel Rees', 'daniel@holderdeord.no', 'hdo/daniel.jpg', 'er daglig leder og en av grunnleggerne av Holder de ord. Han har en mastergrad i statsvitenskap fra NTNU i Trondheim, og har bakgrunn fra TNS Gallup hvor han har jobbet med opinionsundersøkelser og kommunikasjonsanalyse. Daniel har bred erfaring som frilansjournalist, fra NRK Her & Nå, og har tidligere jobbet med å utvikle nettsteder for FNs informasjonskontor for Norden og landsdekkende organisasjoner i Norge. Daniel er også styreleder i Holder de ord.'),
      Person.new('Kristofer Rees', 'kristofer@holderdeord.no', 'hdo/kristofer.jpg', 'er sjef for metode og analyse i Holder de ord. Han har en bachelorgrad i statsvitenskap, og har tidligere studert musikk ved NTNU i Trondheim og Det Kgl. Danske Musikkonservatorium i København. Kristofer sitter også i Holder de ords styre.'),
      Person.new('Tiina Ruohonen', 'tiina@holderdeord.no', 'hdo/tiina.jpg', 'er en av grunnleggerne av Holder de ord, nestleder og sjef for kommunikasjon, presse, og partnerskap. Tiina har en Cand. Mag. i statsvitenskap og juss, og en mastergrad i bærekraftig utvikling og etikk. Hun jobbet i flere år som prosjektleder og rådgiver på klimaområdet, og driver i dag sitt eget selskap som hjelper kunder med utfordringer innenfor klimaspørsmål, etikk, samfunnsansvar, og demokratisk medvirkning. Tiina sitter også i Holder de ords styre.'),
      Person.new('Linn Skorge', 'linn@holderdeord.no',  'hdo/linn.jpg', 'jobber med salg og finansiering i Holder de ord. Linn tar for øyeblikket en mastergrad i politisk økonomi på BI i Oslo. Fra tidligere har hun en bachelorgrad i internasjonal markedsføring, også fra Handelshøyskolen BI. Linn sitter også i Holder de ords styre.'),
      Person.new('Guro Øistensen', nil, nil, 'jobber med metode og det faglige innholdet i Holder de ord. Til daglig er hun Communications Manager i IT-bedriften Logica, hvor hun jobber med internett, intranett, PR og intern kommunikasjon. Guro er utdannet sosiolog fra Universitetet i Oslo. Hun sitter også i Holder de ords styre.')
    ]

    @contributors = [
      Person.new('Alex Asensi'),
      Person.new('Kat Aquino'),
      Person.new('Martin Bekkelund'),
      Person.new('Anders Berg Hansen'),
      Person.new('Cathrine Berg-Nielsen'),
      Person.new('Kristian Bysheim'),
      Person.new('Linn Katrine Erstad'),
      Person.new('Inge Olav Fure'),
      Person.new('Svein Halvor Halvorsen'),
      Person.new('Arne Hassel'),
      Person.new('Jostein Holje'),
      Person.new('Vegard Karevold'),
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
      Person.new('Madeleine Skjelland Eriksen'),
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
      Person.new('Silje Nyløkken'),
      Person.new('Tommy Steinsli'),
      Person.new('Einar Sundin'),
      Person.new('Eirik Swensen'),
      Person.new('Ole Martin Volle')
     ]
  end

  class Person
    attr_reader :name, :image, :email, :bio

    def initialize(name, email = nil, image = nil, bio = nil)
      @name, @email, @image, @bio = name, email, image, bio
    end
  end

end
