class DropNotNullFromAccountsBic < ActiveRecord::Migration
  def change
    change_column :accounts, :encrypted_bic, :string, null: true
  end
end
