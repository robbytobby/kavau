class RemoveManuallyEditedFromBalances < ActiveRecord::Migration[4.2]
  def change
    remove_column :balances, :manually_edited, :boolean
  end
end
