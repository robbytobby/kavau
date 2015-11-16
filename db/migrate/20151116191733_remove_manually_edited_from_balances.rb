class RemoveManuallyEditedFromBalances < ActiveRecord::Migration
  def change
    remove_column :balances, :manually_edited, :boolean
  end
end
