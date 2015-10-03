class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :name, null: false
      t.string :first_name, null: false
      t.string :street_number, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.string :salutation, null: false
      t.string :type, null: false

      t.timestamps null: false
    end
  end
end
