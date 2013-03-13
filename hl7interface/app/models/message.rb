class Message < ActiveRecord::Base
  belongs_to :tag
  attr_accessible :dataSource, :messageControlId, :segment, :composite, :subcomposite, :subsubcomposite, :value
  
  paginates_per 100
end
