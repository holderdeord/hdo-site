module Admin::DashboardHelper
  def percentage_chart_json_for(*percentages)
    result = []
    colors = %w[#019ea2 #e03d25 #332b2e #231f20]

    remaining = 100

    percentages.each_with_index do |percent, idx|
      remaining -= percent
      result << {value: percent, color: colors[idx - colors.size]}
    end

    result << {value: remaining, color: "#4D5360"}

    result.to_json
  end
end