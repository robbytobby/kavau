class CreatePdfs < ActiveRecord::Migration[4.2]
  def change
    create_table :pdfs do |t|
      t.integer :creditor_id, null: false
      t.integer :letter_id, null: false
      t.string :path, null: false

      t.timestamps null: false
    end
  end
end
