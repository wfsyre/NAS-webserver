class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :current_user
  helper_method :is_admin?
  helper_method :directory_hash
  helper_method :require_admin
  @folders_current = false
  @manage_current = false

  def require_login
    redirect_to new_session_path unless session.include? :user_id
  end

  def is_admin?
    (not @user == nil) && @user.permissions > 3
  end

  def require_admin
    @user = User.find(session[:user_id])
    if @user == nil
      redirect_to new_session_path
    end
    redirect_to @user unless session.include? :user_id and @user.permissions > 3
  end

  def current_user
    @user ||= User.find(session[:user_id])  if  session[:user_id]
  end

  def directory_hash(path, accepted_files = nil, name=nil, exclude = [])
    exclude.concat(%w[.. . .git __MACOSX .DS_Store])
    data = {:path => (name || path)}
    data[:files] = files = []
    data[:children] = children = []
    Dir.foreach(path) do |entry|
      next if exclude.include?(entry)
      full_path = File.join(path, entry)
      if File.directory?(full_path)
        if accepted_files == nil or accepted_files.any? full_path
          children << directory_hash(full_path, accepted_files)
        end
      else
        files << {:path => entry}
      end
    end
    data
  end

  def file_list(path, accepted_files = nil, exclude = [])
    exclude.concat(%w[.. . .git __MACOSX .DS_Store])
    files = []
    Dir.foreach(path) do |entry|
      next if exclude.include?(entry)
      full_path = File.join(path, entry)
      unless File.directory?(full_path)
        files << entry
      end
    end
    files
  end

end
