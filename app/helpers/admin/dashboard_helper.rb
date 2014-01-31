module Admin::DashboardHelper
  def percentage_chart_json_for(*percentages)
    result = []
    colors = %w[#019ea2 #019ea2 #019ea2]
    remaining = 100

    percentages.each do |percent|
      remaining -= percent
      result << {value: percent, color: colors.shift}
    end

    result << {value: remaining, color: "#4D5360"}

    result.to_json
  end
end