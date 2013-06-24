module Admin::RepresentativesHelper
  def row_class_for_admin_representative(rep)
    if rep.confirmed?
      "success"
    elsif rep.opted_out?
      "error"
    elsif rep.confirmation_sent_at
      "warning"
    else
      "info"
    end
  end
end
