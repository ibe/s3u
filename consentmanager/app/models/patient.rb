class Patient < ActiveResource::Base
  # should work, needs authentication at the webinterface though
  self.site = S3uLmuConsentmanager::Application.config.s3u_lmu_webinterface_url
end
