module Hdo
  module Utils
    class PropositionSourceGuesser

      def self.parties_for(str)
        result = []

        PARTY_MAP.each do |exp, external_id|
          result << external_id if str =~ exp
        end

        result.uniq
      end

      NEGATIVES = /(?<!bokstav\s|romertall\s)/i

      PARTY_MAP = {
        /\b(#{NEGATIVES}a|ap|arbeiderpartiet|arbeidarpartiet)\b/i => 'A',
        /\b(framstegspartiet|fremskrittspartiet|frp)\b/i          => 'FrP',
        /\b(høyre|høgre|#{NEGATIVES}h)\b/i                        => 'H',
        /\b(kristel(i|e)g folkeparti|krf)\b/i                     => 'KrF',
        /\b(senterpartiet|sp)\b/i                                 => 'Sp',
        /\b(sosialistisk venstreparti|sv)\b/i                     => 'SV',
        /\b(venstre|#{NEGATIVES}v)\b/i                            => 'V',
        /\b(miljøpartiet dei? grønne|mdg)\b/i                     => 'MDG',
      }

    end
  end
end
