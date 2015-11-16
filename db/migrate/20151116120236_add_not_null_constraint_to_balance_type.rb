class AddNotNullConstraintToBalanceType < ActiveRecord::Migration
  def change
    change_column :balances, :type, :string, null: false, default: 'AutoBalance'
  end
end
