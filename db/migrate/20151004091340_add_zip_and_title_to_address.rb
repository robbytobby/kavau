class AddZipAndTitleToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :zip, :string, null: false
    add_column :addresses, :title, :string, null: true
  end
end
