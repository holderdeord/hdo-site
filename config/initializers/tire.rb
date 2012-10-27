#
# Module used to share config among model (indeces)
#

module TireSettings
  LOCALE = {
    nb: {
      language: 'Norwegian',
      stopwords: %w[at av da de den der deres det disse eller en er et for hvis i ikke inn med men nei og slik som til var vil]
    }
  }

  module_function

  def default
    {
      analysis: {
        analyzer: {
          default: {
            type: 'snowball',
            language: locale[:language],
            stopwords: locale[:stopwords].join(",")
          }
        }
      }
    }.with_indifferent_access
  end

  def default_analyzer
    'default'
  end

  def locale
    LOCALE.fetch(I18n.locale)
  end
end

#
# Tire configuration
#

Tire.configure do
  logger Rails.root.join("log/tire_#{Rails.env}.log")
end
