class Patient < ActiveRecord::Base
  has_many :medical_cases, :dependent => :destroy
  attr_accessible :extId, :prename, :surname, :dob, :sex, :extDocId, :consent_status, :self_service_status, :trial_id, :read_status
  paginates_per 7

  validates :extId, :prename, :surname, :extDocId, :presence => true
  validates :sex, :inclusion => { :in => %w(M F) }
  validates :dob, :format => { :with => /[0-9]{4}-[0-9]{2}-[0-9]{2}/ }
  
  after_save :update_remote_apps
  
  def trial
    Trial.find(self.trial_id)
  end

  def update_remote_apps
    @trial = self.trial
    if self.consent_status == 1
      @trial.update_attributes(:recruiting_status => @trial.recruiting_status + 1)
      @cdms_subject = CdmsSubject.new(:prename => self.prename, :surname => self.surname)
      if @cdms_subject.new?
        @cdms_subject.save!
      else
        @cdms_subject.update   
      end
    elsif self.consent_status == 0
      @trial.update_attributes(:recruiting_status => @trial.recruiting_status - 1)
    end
  end
end
