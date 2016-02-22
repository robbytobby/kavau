class AddAccpetedTypesToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :accepted_types, :string
  end
end
