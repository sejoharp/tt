class ApplicationController < ActionController::Base
  protect_from_forgery
	helper_method :current_user

	def current_user
	  @current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def authenticate
    redirect_to login_url, alert: "Not authenticated" if current_user.nil?
	end

	def authorize(user)
		if current_user != user
			session[:user_id] = nil
			redirect_to login_url, alert: "Not authorized" 
		end
	end
end
