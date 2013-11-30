module Hdo
  module Utils
    class PropositionSourceGuesser

      def parties_for(str)
        result = []

        PARTY_MAP.each do |exp, external_id|
          result << external_id if str =~ exp
        end

        result.uniq
      end

      PARTY_MAP = {
        /\b(a|ap|arbeiderpartiet)\b/i                    => 'A',
        /\b(framstegspartiet|fremskrittspartiet|frp)\b/i => 'FrP',
        /\b(høyre|høgre|h)\b/i                           => 'H',
        /\b(kristel(i|e)g folkeparti|krf)\b/i            => 'KrF',
        /\b(senterpartiet|sp)\b/i                        => 'Sp',
        /\b(sosialistisk venstreparti|sv)\b/i            => 'SV',
        /\b(venstre|v)\b/                                => 'V',
      }

    end
  end
end
