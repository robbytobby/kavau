class AddNotNullConstraintToBalanceType < ActiveRecord::Migration[4.2]
  def change
    change_column :balances, :type, :string, null: false, default: 'AutoBalance'
  end
end
