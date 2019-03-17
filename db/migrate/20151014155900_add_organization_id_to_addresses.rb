class AddOrganizationIdToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :organization_id, :integer
  end
end
