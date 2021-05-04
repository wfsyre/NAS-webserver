class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :current_user
  helper_method :is_admin?

  def require_login
    redirect_to new_session_path unless session.include? :user_id
  end

  def is_admin?
    (not @user == nil) && @user[:permissions] > 0
  end

  def current_user
    @current_user ||= User.find(session[:user_id])  if  session[:user_id]
  end
end
