class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation
  attr_accessor :password
  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :name
	validates_uniqueness_of :name

	def authenticate(password)
	  if self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)
	  	true
	  else
	   	false
	  end
	end
	  
	def encrypt_password
	  if password.present?
	  	self.password_salt = BCrypt::Engine.generate_salt
	  	self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
	  end
	end
end
