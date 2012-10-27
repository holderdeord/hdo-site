#
# Module used to share config among model (indeces)
#

module TireSettings
  LOCALE = {
    nb: {
      language: 'Norwegian',
      stopwords: %w[at av da de den der deres det disse eller en er et for hvis i ikke inn med men nei og slik som til var vil].join(',')
    }
  }

  module_function

  def default
    {
      analysis: {
        analyzer: {
          default: {
            type: 'custom',
            tokenizer: 'standard',
            filter: %w[standard lowercase hdo_stop hdo_snowball hdo_decompounder]
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
            word_list: %w[formue skatt eiendom],
            # word_list_path: ""
          }
        }
      }
    }.with_indifferent_access
  end

  def default_analyzer
    'default'
  end

  def locale
    @locale ||= LOCALE.fetch(I18n.locale)
  end
end

#
# Tire configuration
#

Tire.configure do
  logger Rails.root.join("log/tire_#{Rails.env}.log")
end
