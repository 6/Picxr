class RenamePictureOriginalUrlToOriginalId < ActiveRecord::Migration
  def change
    rename_column :pictures, :original_url, :original_permalink_id
  end
end
