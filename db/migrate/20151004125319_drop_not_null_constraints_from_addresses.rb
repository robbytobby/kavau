class DropNotNullConstraintsFromAddresses < ActiveRecord::Migration[4.2]
  def self.up
    change_column :addresses, :first_name, :string, null: true
    change_column :addresses, :street_number, :string, null: true
    change_column :addresses, :zip, :string, null: true
    change_column :addresses, :city, :string, null: true
    change_column :addresses, :country_code, :string, null: true
  end

  def self.down
    change_column :addresses, :first_name, :string, null: false
    change_column :addresses, :street_number, :string, null: false
    change_column :addresses, :zip, :string, null: false
    change_column :addresses, :city, :string, null: false
    change_column :addresses, :country_code, :string, null: false
  end
end
