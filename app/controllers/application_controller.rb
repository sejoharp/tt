class ApplicationController < ActionController::Base
  protect_from_forgery
	helper_method :current_user

	private

	def current_user
	  @current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def authorize
    redirect_to login_url, alert: "Not authorized" if current_user.nil?
	end

  def access_allowed?(interval)
  	current_user == interval.user
  end
end
