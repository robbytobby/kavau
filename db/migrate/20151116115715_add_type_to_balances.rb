class AddTypeToBalances < ActiveRecord::Migration[4.2]
  def change
    add_column :balances, :type, :string
  end
end
