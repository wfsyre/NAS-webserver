class FileTransferController < ApplicationController
  def show
    file = params[:file_dir] + '/' + params[:file_name]
    file += ".#{params[:format]}" if params[:format]
    if File.directory?(file)
      redirect_to :action => :index, :locals => {:output_dir => file + '/'}
    else
      send_file params[:file_dir] + '/' + params[:file_name], :type => "text/csv"
      redirect_to :action => :index
    end
  end
end
