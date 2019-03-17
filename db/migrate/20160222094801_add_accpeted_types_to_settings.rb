class AddAccpetedTypesToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :accepted_types, :string
  end
end
