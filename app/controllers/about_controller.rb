class AboutController < ApplicationController
  skip_before_action :require_login, only: [:show]

  def show
    if session[:user_id] != nil
      @user = User.find(session[:user_id])
    end
  end
end
