class MessageObserver < ActiveRecord::Observer
  def after_save(model)
    previous_messageControlId = Message.select(:messageControlId).order("id DESC").limit(1).offset(1).first
    if (previous_messageControlId.messageControlId != model.messageControlId)
      # ok, we have a new hl7 message, therefor we can save the previous message
      # to the patients/medical_cases/diagnoses hierarchy
      previous = Message.where(:messageControlId => previous_messageControlId.messageControlId)
      patient = previous.where(:segment => "PID")
      medical_case = previous.where(:segment => "PV1")
      diagnosis = previous.where(:segment => "DG1")
      new_patient = Patient.new(
        :extId => patient.select(:value).where(:composite => 3, :subcomposite => 0, :subsubcomposite => 0).first.value,
        :prename => patient.select(:value).where(:composite => 5, :subcomposite => 0, :subsubcomposite => 0).first.value,
        :surname => patient.select(:value).where(:composite => 5, :subcomposite => 1, :subsubcomposite => 0).first.value,
        :dob => patient.select(:value).where(:composite => 7, :subcomposite => 0, :subsubcomposite => 0).first.value,
        :sex => patient.select(:value).where(:composite => 8, :subcomposite => 0, :subsubcomposite => 0).first.value)
      new_patient.save
    end
  end
end
