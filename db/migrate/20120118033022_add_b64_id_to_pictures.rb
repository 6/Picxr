class AddB64IdToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :b64_id, :string
  end
end
