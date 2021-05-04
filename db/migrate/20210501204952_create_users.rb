class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.integer :photos_uploaded, default: 0
      t.integer :videos_uploaded, default: 0
      t.integer :permissions, default: 0
      t.text :folders, default: ""

      t.timestamps
    end
  end
end
