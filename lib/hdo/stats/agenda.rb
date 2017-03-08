require 'csv'

module Hdo
  module Stats
    class Agenda
      def self.generate
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

        data = JSON.parse(File.read(Rails.root.join('public/data/agreement-all-categories-no-budget.json')))

        ranges = ['2009-2013', '2013-2017']
        # ranges = ['2013-2014', '2014-2015']
        range_type = 'by_period'

        empty = {'count' => 0, 'total' => 0}

        STDOUT << CSV.generate(col_sep: "\t") do |csv|
          columns = combinations.flat_map { |c| ranges.map { |r| "#{r}-#{c}" }}

          csv << ['KATEGORIER', *columns.flat_map { |e| ['PROSENT', 'ABSOLUTTE'] }]
          csv << ['', *columns.flat_map { |e| [e, e] }]

          all_data = combinations.flat_map do |combo|
            ranges.flat_map do |range|
              d = data[range_type][range]['all'][combo] || empty

              abs = "#{d['count']}/#{d['total']}"

              pct = if d['total'] != 0
                      (d['count'] / d['total'].to_f) * 100
                    else
                      0
                    end

              [pct, abs]
            end
          end

          csv << ['Alle kategorier', *all_data]

          categories.each do |category|
            row_data = combinations.flat_map do |combo|
              ranges.flat_map do |range|
                d = data[range_type][range]['categories'][category][combo] || empty

                abs = "#{d['count']}/#{d['total']}"

                pct = if d['total'] != 0
                        (d['count'] / d['total'].to_f) * 100
                      else
                        0
                      end

                [pct, abs]
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