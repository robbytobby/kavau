class Change < ActiveRecord::Migration[4.2]
  def change
    rename_column :accounts, :account_address_id, :address_id
    rename_column :accounts, :account_address_type, :address_type
  end
end
