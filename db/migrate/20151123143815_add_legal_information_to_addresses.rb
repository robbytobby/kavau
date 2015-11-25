class AddLegalInformationToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :legal_information, :hstore
  end
end
