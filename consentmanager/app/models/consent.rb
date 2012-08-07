class Consent < ActiveRecord::Base
  belongs_to :subject
  
  def trial
    Trial.find(self.trial_id)
  end
end
