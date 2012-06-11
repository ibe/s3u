class Criterion < ActiveRecord::Base
  belongs_to :trial
  belongs_to :datum
  attr_accessible :value, :criterion_type, :operator, :datum_id, :trial_id
end
