class Consent < ActiveRecord::Base
  belongs_to :subject
  
  after_save :update_studienmonitor

  def trial
    Trial.find(self.trial_id)
  end
  
  private
  
  def update_studienmonitor
    if self.status == 1
      if self.trial.recruiting_status == nil
        self.trial.recruiting_status = 1
      else
        self.trial.recruiting_status = self.trial.recruiting_status + 1
      end
    else
      if self.trial.recruiting_status > 1
        self.trial.recruiting_status = self.trial.recruiting_status - 1
      else
        self.trial.recruiting_status = nil
      end
    end
    self.trial.save
  end
end
