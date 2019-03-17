class AddPersonalDataToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :first_name, :string, null: false
    add_column :users, :name, :string, null: false
    add_column :users, :phone, :text
    add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  end
end
