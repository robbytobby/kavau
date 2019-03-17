class AddInstitutionTypeToContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :institution_type, :string
    rename_column :addresses, :organization_id, :institution_id
  end
end
