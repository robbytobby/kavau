class AddManuallyEditedToBalances < ActiveRecord::Migration[4.2]
  def change
    add_column :balances, :manually_edited, :boolean, default: false
  end
end
