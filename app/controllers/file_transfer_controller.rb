class FileTransferController < ApplicationController
  before_action :require_file_path_param, only: [:index]

  def require_file_path_param
    if params[:path] == nil or params[:path] == ""
      redirect_to file_transfer_index_path(path: "media")
    end
  end

  def index
    @user = User.find(session[:user_id])
    @folders = @user[:folders].split(",")
    @num_folders = @folders.length
    root_dir = "media"
    @media = directory_hash(root_dir, @folders)
    @current_dir = params[:path]
    @split_dir = @current_dir.split("/")
    @current_hash = @media
    @split_dir[1..].each do |f|
      @current_hash = @current_hash[:children].find {|p| p[:path][(p[:path].rindex("/") + 1)..] == f}
    end
  end

  def download
    file = params[:directory] + "/" + params[:file]
    # file += ".#{params[:format]}" if params[:format]
    send_file file, status: 202
  end

  def upload
    uploaded_io = params[:upload_files]
    File.open(Rails.root.join(@current_dir, uploaded_io.original_filename), 'w') do |file|
      file.write(uploaded_io.read)
    end
  end

  def post_params
    params.require(:post).permit(:upload_files => [])
  end
end
