class Request < ActiveRecord::Base
  has_many :criteria
  attr_accessible :prenameContact, :surnameContact, :mailContact, :phoneContact, :description, :approved, :submit
  paginates_per 7
  validates :prenameContact, :surnameContact, :phoneContact, :description, :presence => true
  validates :mailContact, :format => { :with => /[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/ }
end
