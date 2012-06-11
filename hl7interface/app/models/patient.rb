class Patient < ActiveRecord::Base
  has_many :medical_cases
end
