class AddIssuedAtToFund < ActiveRecord::Migration[4.2]
  def change
    add_column :funds, :issued_at, :date, null: false
  end
end
