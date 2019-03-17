class AddLegalFormToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :legal_form, :string, null: true
  end
end
