class Diagnosis < ActiveRecord::Base
  belongs_to :medical_case
  attr_accessible :icd10Code, :icd10Text, :icd10Version, :medical_case_id
  paginates_per 7
  validates :icd10Code, :icd10Text, :icd10Version, :presence => true
end
