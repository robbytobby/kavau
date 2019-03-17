class AddNotesToAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :notes, :text
  end
end
