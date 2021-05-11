class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :current_user
  helper_method :is_admin?
  helper_method :directory_hash
  @folders_current = false
  @manage_current = false

  def require_login
    redirect_to new_session_path unless session.include? :user_id
  end

  def is_admin?
    (not @user == nil) && @user[:permissions] > 3
  end

  def current_user
    @user ||= User.find(session[:user_id])  if  session[:user_id]
  end

  def directory_hash(path, name=nil, exclude = [])
    exclude.concat(%w[.. . .git __MACOSX .DS_Store])
    data = {:path => (name || path)}
    data[:files] = files = []
    data[:children] = children = []
    Dir.foreach(path) do |entry|
      next if exclude.include?(entry)
      full_path = File.join(path, entry)
      if File.directory?(full_path)
        children << directory_hash(full_path, entry)
      else
        files << {:path => entry}
      end
    end
    data
  end

end
