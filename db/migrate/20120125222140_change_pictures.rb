class ChangePictures < ActiveRecord::Migration
  def change
    change_table :pictures do |t|
      t.remove :private_id
      t.rename :b64_id, :permalink_id
    end
    add_column :pictures, :is_private, :boolean
  end
end
