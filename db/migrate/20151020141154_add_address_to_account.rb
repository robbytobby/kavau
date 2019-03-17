class AddAddressToAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :account_address_id, :string, null: false
    add_column :accounts, :account_address_type, :string, null: false
  end
end
