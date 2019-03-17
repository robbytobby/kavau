class AddDefaultToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :default, :boolean, default: false
  end
end
