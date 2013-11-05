class Admin::PropositionsController < AdminController
  def index
    @propositions = Vote.includes(:propositions).order(:time).reverse_order.first(30).flat_map(&:propositions)
  end
end