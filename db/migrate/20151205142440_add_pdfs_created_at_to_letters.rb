class AddPdfsCreatedAtToLetters < ActiveRecord::Migration[4.2]
  def change
    add_column :letters, :pdfs_created_at, :datetime, null: true
  end
end
