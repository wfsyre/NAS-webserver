class UsersController < ApplicationController
  skip_before_action :require_login, only: [:create, :new]

  def new
    p "new"
    @user = User.new
  end

  def manage
    @user = User.find(session[:user_id])
    @users = User.where("permissions < ?", @user[:permissions])
    @folders = @user[:folders].split(",")
    @num_folders = @folders.length
    @num_managed_users = @users.length
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

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end

end
