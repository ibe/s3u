class MedicalCase < ActiveRecord::Base
  belongs_to :patient
  has_many :diagnoses, :dependent => :destroy
  attr_accessible :extCaseId, :funcOu, :nurseOu, :patient_id
end
