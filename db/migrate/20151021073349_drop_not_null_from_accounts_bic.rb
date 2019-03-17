class DropNotNullFromAccountsBic < ActiveRecord::Migration[4.2]
  def change
    change_column :accounts, :encrypted_bic, :string, null: true
  end
end
