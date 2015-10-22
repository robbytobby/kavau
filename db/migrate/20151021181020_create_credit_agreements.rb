class CreateCreditAgreements < ActiveRecord::Migration
  def change
    create_table :credit_agreements do |t|
      t.decimal :amount, precision: 9, scale: 2, null: false
      t.decimal :interest_rate, precision: 4, scale: 2, null: false
      t.integer :cancellation_period, null: false
      t.integer :creditor_id, null: false
      t.integer :account_id, null: false

      t.timestamps null: false
    end
  end
end
