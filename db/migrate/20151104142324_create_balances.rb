class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.decimal :amount, precision: 9, scale: 2, null: false
      t.integer :credit_agreement_id, null: false
      t.date :date, null: false

      t.timestamps null: false
    end
  end
end
