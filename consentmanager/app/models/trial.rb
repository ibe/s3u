class Trial < ActiveResource::Base
  self.site = S3uLmuConsentmanager::Application.config.s3u_lmu_studienmonitor_url
end
