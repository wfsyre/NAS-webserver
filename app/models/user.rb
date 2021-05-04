class User < ApplicationRecord
  has_secure_password
  validates_uniqueness_of :username
  attr_accessor :photos_uploaded
  attr_accessor :videos_uploaded
  attr_accessor :folders

  def add_folder(folder_name)
    @folders.add(folder_name)
  end

  def member?(folder_name)
    @folders.subset?(folder_name)
  end

  def remove_folder(folder_name)
    @folders.delete(folder_name)
  end

  def num_folders
    if @folders != nil
      return @folders.length
    end
    0
  end


end
