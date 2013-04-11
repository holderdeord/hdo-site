module Admin::RepresentativesHelper
  def row_class_for_admin_representative(rep)
    if rep.confirmed?
      return "success"
    elsif rep.confirmation_sent_at
      return "warning"
    else
      return "error"
    end
  end
end
