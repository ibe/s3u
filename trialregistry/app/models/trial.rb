class Trial < ActiveRecord::Base
  has_many :criteria
  has_many :hits
  #has_many :data, :through => :criteria
  #has_many :subjects
  attr_accessible :extId, :description, :recruitingTarget, :recruiting_status, :prenameInvestigator, :surnameInvestigator, :mailInvestigator, :informed_consent
  before_create do |trial|
    trial.recruiting_status = 0
  end
  # deployed to sub uri ("http://foo.bar/trialregistry" instead of "http://foo.bar")
  # therefor having to workaround bug in paperclip
  # see https://github.com/thoughtbot/paperclip/issues/889
  has_attached_file :informed_consent, :url => "/trialregistry/system/:class/:attachment/:id/:style/:filename"
end
