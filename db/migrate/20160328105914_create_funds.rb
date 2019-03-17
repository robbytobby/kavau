class CreateFunds < ActiveRecord::Migration[4.2]
  def change
    create_table :funds do |t|
      t.decimal :interest_rate, precision:4, scale: 2, null: false
      t.string :limit

      t.timestamps null: false
    end
  end
end
