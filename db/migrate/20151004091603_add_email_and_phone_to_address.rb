class AddEmailAndPhoneToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :email, :string, null: true
    add_column :addresses, :phone, :text, null: true
  end
end
