class AddInterestsSumToBalances < ActiveRecord::Migration
  def change
    add_column :balances, :interests_sum, :decimal, precision: 9, scale: 2
  end
end
