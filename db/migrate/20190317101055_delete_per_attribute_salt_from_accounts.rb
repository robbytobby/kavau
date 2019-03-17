class DeletePerAttributeSaltFromAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :encrypted_bic_salt, :string
    remove_column :accounts, :encrypted_owner_salt, :string
    remove_column :accounts, :encrypted_iban_salt, :string
    remove_column :accounts, :encrypted_bank_salt, :string
    remove_column :accounts, :encrypted_name_salt, :string
    add_index :accounts, :encrypted_bic_iv, unique: true
    add_index :accounts, :encrypted_owner_iv, unique: true
    add_index :accounts, :encrypted_iban_iv, unique: true
    add_index :accounts, :encrypted_bank_iv, unique: true
    add_index :accounts, :encrypted_name_iv, unique: true
  end
end
