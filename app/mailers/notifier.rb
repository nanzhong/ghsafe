class Notifier < ActionMailer::Base
  default :from => "notify@ghsafe.com"

  def notify_contacts(user, route)
    user.contacts
    @user = user
    @route_id = route.id
    mail(:to      => (user.contacts.map {|c| c.email }).join(","),
         :subject => "Attention: #{user.name} has activated panic mode")
  end

end
