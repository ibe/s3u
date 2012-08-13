class Patient < ActiveRecord::Base
  has_many :medical_cases
  paginates_per 20
end
