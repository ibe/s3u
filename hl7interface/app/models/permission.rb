class Permission < ActiveRecord::Base
  belongs_to :group
  attr_accessible :dataSource, :segment, :composite, :subcomposite, :subsubcomposite, :value
end
