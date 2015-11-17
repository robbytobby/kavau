class AddSignToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :sign, :integer
    Deposit.all.each do |dep|
      dep.sign = 1
      dep.save
    end
    Disburse.all.each do |dis|
      dis.sign = -1
      dis.save
    end
    change_column :payments, :sign, :integer, null: false
  end

  def down
    remove_column :payments, :sign
  end
end
