class AddTypeToBalances < ActiveRecord::Migration
  def change
    add_column :balances, :type, :string
  end
end
