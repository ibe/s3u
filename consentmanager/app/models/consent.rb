class Consent < ActiveRecord::Base
  belongs_to :subject
  paginates_per 7

  def trial
    Trial.find(self.trial_id)
  end
end
