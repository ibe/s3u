class Datum < ActiveResource::Base
  self.site = S3uLmuWebrequest::Application.config.s3u_lmu_studienmonitor_url
  
  def criteria
    Criterion.find(:all, :conditions => { :datum_id => self.id })
  end
end
