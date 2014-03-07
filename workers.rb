class SendAccountCreated
  include SuckerPunch::Job, Comms
  
  def perform(email, password)
    subject = "[authserv] Your authserv account has been created"
    data = [email, password]
    template = "./user_account.html"
    send_mail(email, subject, data, template)
  end
end

class SendPasswordReset
  include SuckerPunch::Job, Comms
  
  def perform(email, password)
    subject = "[authserv] Your authserv password has been reset"
    data = [password]
    template = "./password_reset.html"
    send_mail(email, subject, data, template)
  end
end