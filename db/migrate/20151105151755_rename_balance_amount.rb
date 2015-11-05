class RenameBalanceAmount < ActiveRecord::Migration
  def change
    rename_column :balances, :amount, :end_amount
  end
end
