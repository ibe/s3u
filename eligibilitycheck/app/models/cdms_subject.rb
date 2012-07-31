class CdmsSubject < ActiveResource::Base
  self.site = S3uLmuAerzteUi::Application.config.s3u_lmu_cdms_url
  self.element_name = "patient"
end