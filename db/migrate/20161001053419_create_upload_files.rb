class CreateUploadFiles < ActiveRecord::Migration
  def change
    create_table :upload_files do |t|
      t.attachment :zip_file_a

      t.timestamps null: false
    end
  end
end
