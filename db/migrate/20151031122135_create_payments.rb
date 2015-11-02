class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 9, scale: 2, null: false
      t.string :type, null: false
      t.date :date, null: false
      t.integer :credit_agreement_id, null: false

      t.timestamps null: false
    end
  end
end
