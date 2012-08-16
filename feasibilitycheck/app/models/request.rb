class Request < ActiveRecord::Base
  has_many :criteria
  attr_accessible :prenameContact, :surnameContact, :mailContact, :phoneContact, :description, :approved, :submit
  paginates_per 7
  validates :prenameContact, :surnameContact, :mailContact, :phoneContact, :description, :presence => true
end
