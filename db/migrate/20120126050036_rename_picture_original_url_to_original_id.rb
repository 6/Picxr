class RenamePictureOriginalUrlToOriginalId < ActiveRecord::Migration
  def change
    rename_column :pictures, :original_url, :original_id
  end
end
