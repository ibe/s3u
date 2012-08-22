class Consent < ActiveRecord::Base
  belongs_to :subject
  paginates_per 7

  validates :trial_id, :subject_id, :numericality => true
  validates :prenamePhysician, :surnamePhysician, :presence => true
  validates :mailPhysician, :format => { :with => /[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/ }
  
  def trial
    Trial.find(self.trial_id)
  end
end
