class UsersController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def new
    p "new"
    @user = User.new
  end

  def create
    if User.find_by_username(params[:username]) != nil
      flash[:error] = "Username #{params[:username]} already exists"
      redirect_to new_user_path
    else
      @user = User.create(username: user_params[:username],
                          password: user_params[:password],
                          folders: "",
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
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end

end
