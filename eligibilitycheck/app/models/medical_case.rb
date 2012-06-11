class MedicalCase < ActiveRecord::Base
  belongs_to :patient
  has_many :diagnoses
  attr_accessible :extCaseId, :funcOu, :nurseOu, :patient_id
end
