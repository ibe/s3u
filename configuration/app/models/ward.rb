class Ward < ActiveRecord::Base
  has_many :contacts
  attr_accessible :description, :name
end
