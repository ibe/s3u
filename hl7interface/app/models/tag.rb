class Tag < ActiveRecord::Base
  has_many :messages
end
