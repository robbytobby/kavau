class CreateLetters < ActiveRecord::Migration
  def change
    create_table :letters do |t|
      t.string :type, null: false
      t.text :subject, null: true
      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
