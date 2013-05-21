module AnswersHelper
  def label_for_status(status)
    klass = 'label '

    case status
    when 'approved'
      klass << 'label-success'
    when 'pending'
      klass << 'label-warning'
    when 'rejected'
      klass << 'label-important'
    end

    klass
  end

  def explanation_for_status(status)
    case status
    when 'pending'
      'Svaret ditt avventer kontroll. Det vil bli publisert så snart vi har moderert det i henhold til <a href="#" data-toggle="modal" data-target="#code-of-conduct">retningslinjene</a>.'
    when 'approved'
      'Svaret ditt er publisert!'
    when 'rejected'
      'Svaret ble ikke godkjent i henhold til <a href="#" data-toggle="modal" data-target="#code-of-conduct">retningslinjene</a>. Du kan skrive et nytt svar under.'
    end
  end
end