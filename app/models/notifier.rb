class Notifier < ActionMailer::Base
  default :from => "notify@ghsafe.com"

  def notify_contacts(user, route)
    user.contacts
    @route_id = route.id
    mail(:to      => (user.contacts.map {|c| c.email }).join(","),
         :subject => "ATTENTION: #{user.name} has activated PANIC MODE")
  end

end
