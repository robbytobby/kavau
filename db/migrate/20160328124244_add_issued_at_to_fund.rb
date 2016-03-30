class AddIssuedAtToFund < ActiveRecord::Migration
  def change
    add_column :funds, :issued_at, :date, null: false
  end
end
