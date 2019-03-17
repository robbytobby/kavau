class ChangeAddressesCountryToCountryCode < ActiveRecord::Migration[4.2]
  def change
    rename_column :addresses, :country, :country_code
  end
end
