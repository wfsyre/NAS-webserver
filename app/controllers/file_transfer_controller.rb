require 'zip'
class FileTransferController < ApplicationController
  before_action :require_file_path_param, only: [:index]

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

  def download_all
    @user = User.find(session[:user_id])
    dir = params[:directory]
    files = params[:files]
    zip_file = Tempfile.new("./temp.zip")
    folder_array = @user[:folders].split(",")
    byebug
    if files != nil and folder_array != nil and folder_array.any? {|d| d == dir}
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
        files.each do |f|
          zipfile.add(f[:path], File.join(dir, f[:path]))
        end
      end
      cleaned_filename = dir.gsub("/", "-")
      zip_data = File.read(zip_file.path)
      send_data zip_data, stats:202, :type => 'application/zip', :filename => cleaned_filename + ".zip"
    end
    zip_file.unlink
  end

  def upload
    params[:upload_files].each do |uploaded_io|
      File.open(Rails.root.join(params[:directory], uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
    end
    redirect_to file_transfer_index_path(path: params[:path])
  end

  private

  def post_params
    params.require(:post).permit(:upload_files => [])
  end

  def require_file_path_param
    if params[:path] == nil or params[:path] == ""
      redirect_to file_transfer_index_path(path: "media")
    end
  end
end
