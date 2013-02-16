module Admin::AnswersHelper

  def representative_options
    opts = Representative.order(:last_name).map do |e|
      ["#{e.display_name} (#{e.latest_party.external_id})", e.id]
    end

    options_for_select opts
  end

end