class RenameBalanceAmount < ActiveRecord::Migration[4.2]
  def change
    rename_column :balances, :amount, :end_amount
  end
end
