class ChangeAddressesCountryToCountryCode < ActiveRecord::Migration
  def change
    rename_column :addresses, :country, :country_code
  end
end
