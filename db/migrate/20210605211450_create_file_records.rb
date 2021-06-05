class CreateFileRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :file_records do |t|
      t.string :name
      t.string :dir
      t.integer :uploader

      t.timestamps
    end
  end
end
