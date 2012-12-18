class Contact < ActiveRecord::Base
  belongs_to :ward
  attr_accessible :mail, :phone, :prename, :surname, :ward_id
end
