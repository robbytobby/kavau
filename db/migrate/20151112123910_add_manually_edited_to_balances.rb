class AddManuallyEditedToBalances < ActiveRecord::Migration
  def change
    add_column :balances, :manually_edited, :boolean, default: false
  end
end
