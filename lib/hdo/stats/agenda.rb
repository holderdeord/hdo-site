require 'csv'

module Hdo
  module Stats
    class Agenda
      def self.generate(opts = {})
        categories = [
          'Arbeidsliv',
          'Arbeidsmiljø',
          'Arbeidsvilkår',
          'Barn',
          'Barnehager',
          'Barnetrygd',
          'Barnevern',
          'Eldreomsorg',
          'Elektrisitet',
          'Energi',
          'Familie',
          'Forurensning',
          'Industri',
          'Innvandrere',
          'Likestilling',
          'Miljøvern',
          'Naturvern',
          'Olje',
          'Oljeomsetning',
          'Oljeutvinning',
          'Polarområder',
          'Svalbard',
          'Svangerskap',
          'Sysselsetting',
          'Trygder',
          'Vassdragsregulering'
        ]

        parties = ['A', 'V', 'KrF'];

        combinations = 2.upto(parties.size).flat_map {|n| parties.combination(n).to_a }
        combinations.map! { |c| c.sort.join(',') }

        data = JSON.parse(File.read(Rails.root.join('public/data/agreement-all-categories.json')))

        ranges = ['2009-2013', '2013-2017']
        # ranges = ['2013-2014', '2014-2015']
        range_type = 'by_period'

        STDOUT << CSV.generate(col_sep: "\t") do |csv|
          columns = combinations.flat_map { |c| ranges.map { |r| "#{r}-#{c}" }}

          csv << ['', *columns]

          all_data = combinations.flat_map do |combo|
            ranges.map do |range|
              d = data[range_type][range]['all'][combo]

              if opts[:absolute]
                "#{d['count']}/#{d['total']}"
              elsif d['total'] != 0
                (d['count'] / d['total'].to_f) * 100
              else
                0
              end
            end
          end

          csv << ['Alle kategorier', *all_data]

          categories.each do |category|
            row_data = combinations.flat_map do |combo|
              ranges.map do |range|
                d = data[range_type][range]['categories'][category][combo]

                if opts[:absolute]
                  "#{d['count']}/#{d['total']}"
                elsif d['total'] != 0
                  (d['count'] / d['total'].to_f) * 100
                else
                  0
                end
              end
            end

            csv << [
              category,
              *row_data
            ]
          end
        end
      end
    end
  end
end