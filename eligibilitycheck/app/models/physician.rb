class Physician < ActiveResource::Base
  self.site = S3uLmuAerzteUi::Application.config.s3u_lmu_studienmonitor_url
end
