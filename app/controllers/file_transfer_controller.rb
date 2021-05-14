class FileTransferController < ApplicationController
  before_action :require_file_path_param, only: [:index]

  def index
    if (params[:path] == nil) or (params[:path] == "")
      redirect_to file_transfer_index_path(path: "media")
    end
    @user = User.find(session[:user_id])
    @folders = @user[:folders].split(",")
    @num_folders = @folders.length
    root_dir = "media"
    @media = directory_hash(root_dir, @folders)
    @current_dir = params[:path]
    @split_dir = @current_dir.split("/")
    @current_hash = @media
    @split_dir[1..].each do |f|
      @current_hash = @current_hash[:children].find {|p| p[:path] == f}
    end
    # file = params[:file_dir] + '/' + params[:file_name]
    # file += ".#{params[:format]}" if params[:format]
    # if File.directory?(file)
    #   redirect_to :action => :index, :locals => {:output_dir => file + '/'}
    # else
    #   send_file params[:file_dir] + '/' + params[:file_name], :type => "text/csv"
    #   redirect_to :action => :index
    # end
  end
end
