class Subject < ActiveRecord::Base
  has_many :consents
  paginates_per 7
  validates :prename, :surname, :presence => true
end
