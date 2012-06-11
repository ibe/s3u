class Trial < ActiveRecord::Base
  has_many :criteria
  #has_many :data, :through => :criteria
  #has_many :subjects
  attr_accessible :extId, :description, :recruitingTarget, :recruiting_status, :prenameInvestigator, :surnameInvestigator, :mailInvestigator, :informed_consent
  
  has_attached_file :informed_consent
end
