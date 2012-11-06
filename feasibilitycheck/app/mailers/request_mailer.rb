class RequestMailer < ActionMailer::Base
  default from: S3uLmuWebrequest::Application.config.mailer_sender
  
  def welcome_email(user,url)
    @user = user
    @url = url
    #mail( :to => user.email, :subject => "hello world" )
    mail( :to => S3uLmuWebrequest::Application.config.mailer_recipient, :subject => "[S3U][Feasibility] Willkommen beim Protocol Feasibility Check" )
  end
end
