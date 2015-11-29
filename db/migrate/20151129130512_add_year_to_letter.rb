class AddYearToLetter < ActiveRecord::Migration
  def change
    add_column :letters, :year, :integer
  end
end
