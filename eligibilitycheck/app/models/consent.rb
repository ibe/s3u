class Consent < ActiveResource::Base
  self.site = S3uLmuAerzteUi::Application.config.s3u_lmu_consentmanager_url
end
