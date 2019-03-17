class AddProjectAddressIdToFund < ActiveRecord::Migration[4.2]
  def change
    add_column :funds, :project_address_id, :integer, null: false
  end
end
