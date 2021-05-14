class UsersController < ApplicationController
  skip_before_action :require_login, only: [:create, :new]
  before_action :require_admin, only: [:manage_user, :manage]
  before_action :require_file_path_param, only: [:manage]


  def new
    p "new"
    @user = User.new
  end

  def manage
    @user = User.find(session[:user_id])
    @users = User.where("permissions <= ?", @user[:permissions])
    @folders = @user[:folders].split(",")
    @num_folders = @folders.length
    @num_managed_users = @users.length
    root_dir = "media"
    @root = directory_hash root_dir
    @current_dir = params[:path]
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
    redirect_to user_manage_path
  end

  def create
    if User.find_by_username(params[:username]) != nil
      flash[:error] = "Username #{params[:username]} already exists"
      redirect_to new_user_path
    else
      @user = User.create(username: user_params[:username],
                          password: user_params[:password],
                          folders: "",
                          admin: false,
                          photos_uploaded: 0,
                          videos_uploaded: 0)
      if @user.save
        session[:user_id] = @user.id
        redirect_to @user
      else
        flash[:error] = "Error: could not create account"
        redirect_to new_user_path
      end
    end
  end

  def show
    @user = User.find(session[:user_id])
    @folders = @user[:folders].split(",")
    @num_folders = @folders.length
    @photos_num = @user[:photos_uploaded]
    @vids_num = @user[:videos_uploaded]
    @permissions = @user[:permissions]
  end

  def manage_user
    @user = User.find(session[:user_id])
    @managed_user = User.find(params[:id])
    @folders = @managed_user[:folders].split(",")
    @num_folders = @folders.length
    @photos_num = @managed_user[:photos_uploaded]
    @vids_num = @managed_user[:videos_uploaded]
    @permissions = @managed_user[:permissions]
  end

  def change_folder
    @managed_user = User.find(params[:id])
    folder = params[:folder]
    user_folders = @managed_user[:folders].split(",")
    user_folders.delete folder
    @managed_user[:folders] = user_folders.join(",")
    @managed_user.save
    redirect_to manage_user_path + "/" + params[:id]
  end

  def promote
    promoted_user = User.find(params[:id])
    if promoted_user[:permissions] < 10
      promoted_user[:permissions] += 1
      promoted_user.save
      redirect_to user_manage_path
    end
  end

  def demote
    promoted_user = User.find(params[:id])
    if promoted_user[:permissions] > 0
      promoted_user[:permissions] -= 1
      promoted_user.save
      redirect_to user_manage_path
    end
  end

  def remove
    User.delete(params[:id])
    redirect_to user_manage_path
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end

end
