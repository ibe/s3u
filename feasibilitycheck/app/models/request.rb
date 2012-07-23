class Request < ActiveRecord::Base
  has_many :criteria
  attr_accessible :prenameContact, :surnameContact, :mailContact, :phoneContact, :description, :approved, :submit
end
