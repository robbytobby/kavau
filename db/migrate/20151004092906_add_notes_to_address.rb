class AddNotesToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :notes, :text
  end
end
