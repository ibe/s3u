class RequestMailer < ActionMailer::Base
  default from: S3uLmuWebrequest::Application.config.mailer_sender
  
  def welcome_email(user)
    @user = user
    @url = "http://example.com"
    #mail( :to => user.email, :subject => "hello world" )
    mail( :to => S3uLmuWebrequest::Application.config.mailer_recipient, :subject => "hello world" )
  end
end
