SMTP = {
  address: 'smtp.sendgrid.net',
  port: '25',
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  authentication: :plain
}    

AUTHSERV_ADMIN = 'no-reply@authserv'
TIME_FORMAT = 'UTC %l:%M %p'
DATE_FORMAT = '%d-%b-%Y'
DATETIME_FORMAT = 'UTC %k:%M, %d-%b-%y'

module Security
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def encrypt(user, plaintext_password, salt)
    secure_digest(user, plaintext_password, salt)
  end

  def make_token
    generate_uuid
  end  

  def make_temporary_password
    secure_digest(Time.now, (1..5).map{ rand.to_s })[0..8]
  end

  def generate_uuid
    SecureRandom.uuid
  end
  
end

module Web
  def require_login      
    redirect "/login" unless session[:user]
    sess = Session[uuid: session[:user]]
    @user = sess.user
  end
  
  def snippet(page, options={})
    haml page, options.merge!(layout: false)
  end
  
end

module Comms

  def send_mail(recipient, subject, data, template)    
    Pony.options = {from: AUTHSERV_ADMIN, via: :smtp, via_options: SMTP}
    eml = File.new template
    html_body = sprintf(eml.read, *data)    
    Pony.mail to: recipient, subject: subject, html_body: html_body
  end
  
end