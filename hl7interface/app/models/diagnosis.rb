class Diagnosis < ActiveRecord::Base
  belongs_to :medical_case
  paginates_per 20
end
