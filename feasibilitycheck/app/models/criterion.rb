class Criterion < ActiveRecord::Base
  belongs_to :request
  #belongs_to :datum
  attr_accessible :criterion_type, :operator, :value, :datum_id
  validates :criterion_type, :operator, :value, :presence => true

  def datum
    Datum.find(self.datum_id)
  end
end
