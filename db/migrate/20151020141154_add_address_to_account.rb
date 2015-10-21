class AddAddressToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :account_address_id, :string, null: false
    add_column :accounts, :account_address_type, :string, null: false
  end
end
