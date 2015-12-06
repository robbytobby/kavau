class AddPdfsCreatedAtToLetters < ActiveRecord::Migration
  def change
    add_column :letters, :pdfs_created_at, :datetime, null: true
  end
end
