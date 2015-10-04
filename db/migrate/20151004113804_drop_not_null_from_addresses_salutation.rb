class DropNotNullFromAddressesSalutation < ActiveRecord::Migration
  def self.up
    change_column :addresses, :salutation, :string, null: true
  end

  def self.down
    change_column :addresses, :salutation, :string, null: false
  end
end
