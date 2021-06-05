class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create, :new]

  def new
  end

  def create
    @user = User.find_by(username: params[:username])

    if !!@user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to @user
    else
      message = "Username and password combination not recognized"
      redirect_to new_session_path, notice: message
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been signed out"
    redirect_to new_session_path
  end
end