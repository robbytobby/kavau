class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :encrypted_bic, null: false
      t.string :encrypted_owner, null: true
      t.string :encrypted_iban, null: false
      t.string :encrypted_bank, null: false
      t.string :encrypted_name, null: true
      t.string :encrypted_bic_salt
      t.string :encrypted_owner_salt
      t.string :encrypted_iban_salt
      t.string :encrypted_bank_salt
      t.string :encrypted_name_salt
      t.string :encrypted_bic_iv
      t.string :encrypted_owner_iv
      t.string :encrypted_iban_iv
      t.string :encrypted_bank_iv
      t.string :encrypted_name_iv
      t.timestamps null: false
    end
  end
end
