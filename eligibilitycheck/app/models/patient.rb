class Patient < ActiveRecord::Base
  has_many :medical_cases
  attr_accessible :extId, :prename, :surname, :dob, :sex, :extDocId, :consent_status, :self_service_status
  
  def trial
    Trial.find(self.trial_id)
  end
end
