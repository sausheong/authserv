require 'sequel'
require 'securerandom'

DB = Sequel.connect 'postgres://authserv:authserv@localhost:5432/authserv'
DB.extension :pagination

class User < Sequel::Model
  include Security
  many_to_many :resources
  one_to_many :sessions
  def before_create
    super
    self.uuid = generate_uuid
    self.salt = generate_uuid
    self.created_at = DateTime.now
  end   
  
  def set_password(plaintext)
    self.update(password: encrypt(email, plaintext, salt))
  end
  
  def generate_session
    Session.create uuid: generate_uuid, user: self
  end
  
  def valid_password?(plaintext)
    enc = encrypt(email, plaintext, salt)
    enc == password
  end
  
  def has_resource?(resource)
    # to be implemented
  end
  
  def add_resource(resource)
    # to be implemented
  end
  
end

class Resource < Sequel::Model
  many_to_many :users
  def before_create
    super
    self.uuid = SecureRandom.uuid
    self.created_at = DateTime.now
  end   

end

class Session < Sequel::Model
  many_to_one :user
  def before_create
    super
    self.created_at = DateTime.now
  end   
end