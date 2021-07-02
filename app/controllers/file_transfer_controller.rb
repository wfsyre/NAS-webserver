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
    records = FileRecord.where(:dir => @current_dir)
    @current_hash[:files].each do |file|
      rec = records.find {|f| f.name == file[:path]}
      if rec != nil
        file[:uploader] = User.find(rec.uploader).username
        file[:id] = rec.id
      else
        me = User.find_by_username("wfsyre")
        FileRecord.create(name: file[:path],
                          dir: params[:path],
                          uploader: me.id)
        file[:uploader] = me.username
        extension = file[:path].split(".")[-1]
        image_extensions = %w[png jpg gif]
        if image_extensions.none? {|ext| ext.casecmp(extension) == 0}
          me.videos_uploaded += 1
        else
          me.photos_uploaded += 1
        end
        me.save
      end
    end
    @current_hash[:children].each do |child|
      contributors = Hash.new 0
      FileRecord.where(:dir => @current_dir).map { |c| contributors[c.uploader] += 1}
      if contributors.size == 1
        child[:uploader] = User.find(contributors.keys[0]).username
        child[:num_uploaders] = 1
      else
        child[:uploader] = "Multiple Contributors"
        child[:num_uploaders] = contributors.size
      end
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
    zip_file = Tempfile.new("./temp.zip")
    folder_array = @user.folders.split(",")
    files = file_list dir
    if folder_array != nil and folder_array.any? {|d| d == dir}
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
        files.each do |f|
          zipfile.add(f, File.join(dir, f))
        end
      end
      first_slash = dir.index("/") + 1
      first_slash = 0 if first_slash == nil
      cleaned_filename = dir[first_slash..].gsub("/", "-")
      zip_data = File.read(zip_file.path)
      send_data zip_data, stats:202, :type => 'application/zip', :filename => cleaned_filename + ".zip"
    end
    zip_file.unlink
  end

  def download_selected
    @user = User.find(session[:user_id])
    file_ids = params[:file_ids].split(",")
    folder_array = @user.folders.split(",")
    zip_file = Tempfile.new("./temp.zip")
    files = []
    dir = nil
    file_ids.each do |f|
      rec = FileRecord.find(Integer(f))
      dir = rec.dir
      files.append({name: rec.name, dir: rec.dir})
    end
    if folder_array != nil and dir != nil and folder_array.any? {|d| d == dir}
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
        files.each do |f|
          p f[:name]
          zipfile.add(f[:name], File.join(f[:dir], f[:name]))
        end
        p "here1"
      end
      p "here2"
      first_slash = dir.index("/") + 1
      first_slash = 0 if first_slash == nil
      cleaned_filename = dir[first_slash..].gsub("/", "-")
      p cleaned_filename
      zip_data = File.read(zip_file.path)
      p "here3"
      send_data zip_data, stats:202, :type => 'application/zip', :filename => cleaned_filename + ".zip"
      p "here4"
    end
    zip_file.unlink
  end

  def upload
    image_extensions = %w[png jpg gif]
    @user = User.find(session[:user_id])
    params[:upload_files].each do |uploaded_io|
      unless File.file? Rails.root.join(params[:directory], uploaded_io.original_filename)
        File.open(Rails.root.join(params[:directory], uploaded_io.original_filename), 'wb') do |file|
          FileRecord.create(name: uploaded_io.original_filename.to_s,
                                          dir: params[:directory].to_s,
                                          uploader: session[:user_id])
          file.write(uploaded_io.read)
          extension = uploaded_io.original_filename.split(".")[-1]
          if image_extensions.none? {|ext| ext.casecmp(extension) == 0}
            @user.videos_uploaded += 1
          else
            @user.photos_uploaded += 1
          end
        end
      end
    end
    @user.save
    redirect_to file_transfer_index_path(path: params[:directory])
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
