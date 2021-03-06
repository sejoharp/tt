class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation, :worktime, :overtime
  attr_accessor :password
  before_save :encrypt_password
  before_save :set_default
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :name
  validates_presence_of :worktime
	validates_uniqueness_of :name
	validates :worktime, :numericality => { :greater_than_or_equal_to => 0 }

	def authenticate(password)
	  self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)
	end
	  
	def encrypt_password
	  if password.present?
	  	self.password_salt = BCrypt::Engine.generate_salt
	  	self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
	  end
	end

	def set_default
		if not self.overtime.present?
			self.overtime = 0
		end
	end
end
