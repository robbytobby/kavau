class AddLegalInformationToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :legal_information, :hstore
  end
end
