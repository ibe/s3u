class MedicalCase < ActiveRecord::Base
  belongs_to :patient
  has_many :diagnoses
  paginates_per 20
end
