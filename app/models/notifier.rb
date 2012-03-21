class Notifier < ActionMailer::Base
  default :from => "notify@ghsafe.com"

  def notify_contacts(user)
    user.contacts
    mail(:to => (user.contacts.map {|c| c.email }).join(","))
  end

end
