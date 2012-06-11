class MedicalCase < ActiveRecord::Base
  belongs_to :patient
  has_many :diagnoses
end
