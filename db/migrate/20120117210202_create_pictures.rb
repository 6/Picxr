class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :picture_file_name
      t.string :picture_content_type
      t.integer :picture_file_size
      t.datetime :picture_updated_at
      t.string :original_url
      t.integer :creator_id
      t.string :private_id

      t.timestamps
    end
  end
end
