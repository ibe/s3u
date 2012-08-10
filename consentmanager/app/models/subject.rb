class Subject < ActiveRecord::Base
  has_many :consents
  paginates_per 7
end
