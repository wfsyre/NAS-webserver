class UsersController < ApplicationController
  skip_before_action :require_login, only: [:create, :new]

  def new
    @new_user = User.new
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
      if not @user.new_record?
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
    unless session[:user_id].to_s.eql? params[:id]
      if is_admin?
        redirect_to admin_show_path(id: params[:id])
      else
        redirect_to @user
      end
    end
    @folders = @user[:folders].split(",")
    @files = FileRecord.where(uploader: @user[:id]).order('name ASC')
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
