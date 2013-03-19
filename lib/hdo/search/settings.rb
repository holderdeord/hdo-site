module Hdo
  module Search
    module Settings
      LOCALE = {
        nb: {
          language: 'Norwegian',
          stopwords: %w[at av da de den der deres det disse eller en er et for hvis i ikke inn med men nei og slik som til var vil].join(','),
        }
      }

      module_function

      def default
        @default ||= {
          analysis: {
            analyzer: {
              hdo_analyzer: {
                alias: %w[default_index],
                type: 'custom',
                tokenizer: 'standard',
                filter: default_filters
              },
              hdo_search: {
                alias: %w[default_search],
                type: 'custom',
                tokenizer: 'standard',
                # don't decompound words in the queries
                filter: default_filters - %w[hdo_decompounder]
              }
            },
            filter: {
              hdo_snowball: {
                type: 'snowball',
                language: locale.fetch(:language)
              },
              hdo_stop: {
                type: 'stop',
                stopwords: locale.fetch(:stopwords)
              },
              hdo_decompounder: {
                type: 'dictionary_decompounder',
                word_list_path: word_list_path
              },
              hdo_synonym: {
                type: "synonym",
                synonyms_path: synonyms_path
              }
            }
          }
        }.with_indifferent_access
      end

      def default_analyzer
        'hdo_analyzer'
      end

      def default_filters
        %w[standard lowercase hdo_synonym hdo_stop hdo_snowball hdo_decompounder]
      end

      def locale
        @locale ||= LOCALE.fetch(I18n.locale)
      end

      def word_list_path
        config_path_for "words.#{I18n.locale}.txt"
      end

      def synonyms_path
        config_path_for "synonyms.#{I18n.locale}.txt"
      end

      def config_path_for(filename)
        if Rails.env.production? || Rails.env.staging?
          "/etc/elasticsearch/hdo.#{filename}"
        else
          Rails.root.join("config/search/#{filename}").to_s
        end
      end

      def models
        [
          Issue,
          ParliamentIssue,
          Party,
          Promise,
          Proposition,
          Representative,
          Vote
        ]
      end

    end
  end
end
