class AdminController < ApplicationController
  before_action :require_admin
  before_action :require_file_path_param, only: [:index]

  def require_file_path_param
    if params[:path] == nil or params[:path] == ""
      if session[:path] != nil and session[:path] != ""
        redirect_to path: session[:path]
      else
        redirect_to path: "media"
      end
    end
  end

  def show
    @user = User.find(session[:user_id])
    @managed_user = User.find(params[:id])
    @folders = @managed_user[:folders].split(",")
    @num_folders = @folders.length
    @photos_num = @managed_user[:photos_uploaded]
    @vids_num = @managed_user[:videos_uploaded]
    @permissions = @managed_user[:permissions]
  end

  def destroy
  end

  def index
    @user = User.find(session[:user_id])
    @users = User.where("permissions <= ?", @user[:permissions])
    @folders = @user[:folders].split(",")
    @num_folders = @folders.length
    @num_managed_users = @users.length
    root_dir = "media"
    @root = directory_hash root_dir
    @current_dir = params[:path]
    session[:path] = @current_dir
    @split_dir = @current_dir.split("/")
    @current_hash = @root
    @split_dir[1..].each do |f|
      @current_hash = @current_hash[:children].find {|p| p[:path][(p[:path].rindex("/") + 1)..] == f}
    end
  end

  def change
    affected_users = params[:users]
    folders_to_add = params[:folders]
    if affected_users == nil or folders_to_add == nil
      return
    end
    affected_users.each do |user|
      current_user = User.find(user.to_i)
      folders_to_add.each do |f|
        if current_user[:folders].split(",").count(f) == 0
          if current_user[:folders].length == 0
            current_user[:folders] += f
          else
            current_user[:folders] += "," + f
          end
          current_user.save
        end
      end
    end
    redirect_to admin_index_path(path: session[:path])
  end

  def change_folder
    @managed_user = User.find(params[:id])
    folder = params[:folder]
    user_folders = @managed_user[:folders].split(",")
    user_folders.delete folder
    @managed_user[:folders] = user_folders.join(",")
    @managed_user.save
    redirect_to params[:id]
  end

  def promote
    promoted_user = User.find(params[:id])
    if promoted_user[:permissions] < 10
      promoted_user[:permissions] += 1
      promoted_user.save
      byebug
      redirect_to admin_index_path(path: session[:path])
    end
  end

  def demote
    promoted_user = User.find(params[:id])
    if promoted_user[:permissions] > 0
      promoted_user[:permissions] -= 1
      promoted_user.save
      redirect_to admin_index_path(path: session[:path])
    end
  end

  def remove
    User.delete(params[:id])
    redirect_to admin_index_path(path: session[:path])
  end
end
