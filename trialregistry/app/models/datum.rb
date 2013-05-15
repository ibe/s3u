class Datum < ActiveRecord::Base
  has_many :criteria
  #has_many :trials, :through => :criteria
  attr_accessible :description, :segment, :composite, :subcomposite, :subsubcomposite, :hint, :regex, :hint_short, :data_source
end
