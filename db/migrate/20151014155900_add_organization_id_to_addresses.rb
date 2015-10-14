class AddOrganizationIdToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :organization_id, :integer
  end
end
