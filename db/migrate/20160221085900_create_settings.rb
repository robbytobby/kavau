class CreateSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :settings do |t|
      t.string :category, null: false
      t.string :group
      t.string :sub_group
      t.string :name, null: false
      t.text :value
      t.boolean :obligatory, default: false
      t.string :type
      t.string :unit
      t.string :default
      t.float :number

      t.timestamps null: false
    end
  end
end
