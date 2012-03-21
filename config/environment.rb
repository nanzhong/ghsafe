# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base.smtp_settings = {
  :user_name => "nan.zhong@ghsafe.com",
  :password => "GHSfydp12",
  :domain => "ghsafe.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

# Initialize the rails application
Ghsafe::Application.initialize!
