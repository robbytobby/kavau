class AddLegalFormToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :legal_form, :string, null: true
  end
end
