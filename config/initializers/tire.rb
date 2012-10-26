#
# Module used to share config among model (indeces)
#

module TireSettings
  module_function

  def default
    {
      analysis: {
        analyzer: {
          norwegian_snowball: {
            type: 'snowball',
            language: 'Norwegian'
          }
        }
      }
    } #.with_indifferent_access
  end

  def default_analyzer
    'norwegian_snowball'
  end
end

#
# Tire configuration
#

Tire.configure do
  logger Rails.root.join("log/tire_#{Rails.env}.log")
end
