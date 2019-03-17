class AddInterestsSumToBalances < ActiveRecord::Migration[4.2]
  def change
    add_column :balances, :interests_sum, :decimal, precision: 9, scale: 2
  end
end
