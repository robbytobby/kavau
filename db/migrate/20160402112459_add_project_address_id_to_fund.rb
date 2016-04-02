class AddProjectAddressIdToFund < ActiveRecord::Migration
  def change
    add_column :funds, :project_address_id, :integer, null: false
  end
end
