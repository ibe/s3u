class Patient < ActiveRecord::Base
  has_many :medical_cases, :dependent => :destroy
  attr_accessible :extId, :prename, :surname, :dob, :sex, :extDocId, :consent_status, :self_service_status, :trial_id
  paginates_per 7

  validates :extId, :prename, :surname, :extDocId, :consent_status, :self_service_status, :presence => true
  validates :sex, :inclusion => { :in => %w(M F) }
  validates :dob, :format => { :with => /[0-9]{4}-[0-9]{2}-[0-9]{2}/ }
  
  after_save :update_studienmonitor
  
  def trial
    Trial.find(self.trial_id)
  end

  def update_studienmonitor
    @trial = self.trial
    if self.consent_status == 1
      @trial.update_attributes(:recruiting_status => @trial.recruiting_status + 1)
    else
      @trial.update_attributes(:recruiting_status => @trial.recruiting_status - 1)
    end
  end

end
