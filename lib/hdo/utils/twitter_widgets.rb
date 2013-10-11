module Hdo
  module Utils

    #
    # includer should have link_to
    #

    module TwitterWidgets

      #
      # These widgets are created with the following accounts:
      #
      # * @holderdeord
      # * @hdotimelines
      #

      TWITTER_WIDGET_IDS = {
        "abidraja"        => "316893415021363200",
        "abwerp"          => "316893905289355264",
        "ajiversen"       => "316871610831355905",
        "akselhagen"      => "316869441499570176",
        "alfholme"        => "316869842470834176",
        "andersanundsen"  => "316868792577818624",
        "AnnaLjunggren"   => "316871912057880577",
        "annemaritb"      => "316868915428990976",
        "annetwh"         => "316893968535273472",
        "annhegeler"      => "316871842780549120",
        "arhelset"        => "316869711101034496",
        "arvekambe"       => "316871682595885057",
        "audunlysbakken"  => "316871932064694272",
        "BakkeJensen"     => "316868859548270592",
        "bardvegar"       => "316893602884222976",
        "BentHHoyre"      => "316869943318675456",
        "DagTerjeA"       => "316868771799244800",
        "davoy"           => "316869143561371648",
        "Draeggers"       => "316869124682813440",
        "Eirikap"         => "316893542171672576",
        "eivindnb"        => "316872124767813633",
        "elsemay"         => "316868946844327937",
        "endreskjervo"    => "316893557082423297",
        "enrakiv"         => "316893637504024576",
        "erlendwiborg"    => "316893920867008513",
        "erlingsande"     => "316893494616657921",
        "erna_solberg"    => "316893588585848832",
        "evakristin"      => "316869539256209408",
        "fabena"          => "316868702651940865",
        "filiprygg"       => "316893464178606081",
        "frphaugland"     => "316869604750278657",
        "FrP_HelgeAndre"  => "316872069860179968",
        "GeirJBekkevold"  => "316868896927916032",
        "geirpo"          => "316892416080748544",
        "ginabarstad"     => "316868874329006082",
        "gormk"           => "316871724136271872",
        "gunvoreldegard"  => "316869194786414592",
        "hadiatajik"      => "316893723457884161",
        "HakonHaugli"     => "316869625637900288",
        "HallerakerH"     => "316869462018105346",
        "hanekamhaug"     => "316869500836388864",
        "HaraldTom"       => "316872052000817153",
        "heiatina"        => "316869031011418112",
        "helgape"         => "316892385592348672",
        "HildeNyvoll"     => "316872105251700736",
        "hoksrud"         => "316869811533651969",
        "Hoybraten"       => "316871571471998976",
        "IbThomsen"       => "316893752687988736",
        "IdaMarieHolen"   => "316869829216837632",
        "ingamarte"       => "316893767246417920",
        "IngridHeggo"     => "316869648194867201",
        "irehanse"        => "316871647288238080",
        "irenelnordahl"   => "316872086381531136",
        "jantoresanner"   => "316893508709515264",
        "jennyklinge"     => "316871759909486593",
        "jensstoltenberg" => "316893666109169664",
        "jettefc"         => "316869064809119744",
        "jonasgahrstore"  => "316893695389605888",
        "jongdale"        => "316869109553963008",
        "jorodd"          => "316868842758471680",
        "KAHareide"       => "316869584332398592",
        "kandidaten"      => "316893431102316544",
        "karesim"         => "316893526552092673",
        "karhenr"         => "316869728549347328",
        "karikjonaaskjos" => "316871741035134976",
        "KarinSWoldseth"  => "316893951720296448",
        "karin_yrvin"     => "316893982842032129",
        "ketilso"         => "316893621079130112",
        "kjellingolf"     => "316893443521658880",
        "knut_gravraak"   => "316869370435469313",
        "konservativ"     => "316871594783940608",
        "KrFDagrun"       => "316869210217267200",
        "KristinVinje"    => "316893872812859392",
        "ktoppe"          => "316893807176187904",
        "lailagustavsen"  => "316869403671134208",
        "LailaThorsen"    => "316893787798519810",
        "larsegeland"     => "316869159243882496",
        "LarsJoakimH"     => "316869560810741761",
        "lassejul"        => "316871666468790272",
        "lenev"           => "316893887648104449",
        "Lindacath"       => "316869689781391360",
        "LineHjemdal"     => "316869795217805312",
        "LiseChristoffer" => "316869090033664000",
        "lottegrepp"      => "316871781413691392",
        "mariannemar"     => "316871951392051200",
        "MariLundArnem"   => "316868827415724032",
        "MasudGh"         => "316869298230542336",
        "Mazyar_Keshvari" => "316871705446457345",
        "MiljoHeidi"      => "316893709386006528",
        "nodseth"         => "316892338905550849",
        "Olovgr"          => "316869388793942016",
        "OyvindHaabrekke" => "316869903099502592",
        "PedersenW"       => "316892370815815680",
        "PerKristianFoss" => "316869262440538112",
        "perrune"         => "316869779019403264",
        "petersgitmark"   => "316869336302227456",
        "PMBorgli"        => "316868931644166144",
        "pwamundsen_frp"  => "316868756544569344",
        "rasmusjmh"       => "388750238430674944",
        "RigmorAEide"     => "316869175773634560",
        "rigmorap"        => "316868737720520705",
        "Sigvald0"        => "316869519782055936",
        "SiriMHoyre"      => "316871974934675456",
        "Sivlen"          => "316893680906674176",
        "Siv_Jensen_FrP"  => "316871631706398720",
        "Sletbakk"        => "316893573335367680",
        "snorrevalen"     => "316893853401628673",
        "SolveigHorne"    => "316869884673925120",
        "spdama"          => "316872031813632000",
        "StineRenate"     => "316869923857108994",
        "stokkangrande"   => "316893651307462656",
        "stortingsrepr"   => "316893478867058688",
        "susannebratli"   => "316868976552591360",
        "SVakhtar"        => "316869046547124224",
        "SveinFlatten"    => "316869228131127296",
        "SVHallgeir"      => "316871800271290369",
        "SVHeikki"        => "316869858472108033",
        "SVKristin"       => "316869481056043008",
        "SylviListhaug"   => "316871898292158465",
        "tagep"           => "316892400867999744",
        "terjeaa"         => "316868721027194880",
        "tetzschner"      => "316893737890484224",
        "thbreen"         => "316868992956514304",
        "ThorErikAP"      => "316869245810118657",
        "tomascarcher"    => "316868808365187072",
        "Tomstroemstad"   => "316892356941070337",
        "Tone_Liljeroth"  => "316871879338102786",
        "TorBremer"       => "316869015240851456",
        "tordlien"        => "316871859662618624",
        "torehagebakken"  => "316869423229190144",
        "TorgeirM"        => "316871996006862848",
        "torgeirm"        => "316872015002869760",
        "ToveBrandvik"    => "316868961486651392",
        "ToveLiseTorve"   => "316893822246322176",
        "Trettebergstuen" => "316893837194821632",
        "Trinesg"         => "316869354878799872",
        "trondhell"       => "316869667639660544",
        "trond_giske"     => "316869316714827776",
        "TrulsWickholm"   => "316893935622557696",
        "ulfleirstein"    => "316871820122931200",
        "viggoFO"         => "316869282720006144",
      }

      TWITTER_SCRIPT = '<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>'

      def twitter_widget_for(twitter_id)
        widget_id = TWITTER_WIDGET_IDS[twitter_id] or return

        # see https://dev.twitter.com/docs/embedded-timelines
        html_opts = {
          class: 'twitter-timeline',
          # width: '300',  # min: 180px, max 520px
          # height: '500', # min: 200px
          height: '310px',
          data: {
            # 'border-color' => '#...'
            'dnt'       => 'true',      # do not track
            'widget-id' => widget_id,
            'lang'      => "no",
            'link-color' => '#019ea2',
            # 'chrome'    => 'noheader nofooter noborders transparent'
            'chrome' => 'noheader nofooter'
          }
        }

        link = link_to "Tweets fra @#{twitter_id}", "https://twitter.com/#{twitter_id}", html_opts
        "#{link} #{TWITTER_SCRIPT}".html_safe
      end

    end
  end
end
