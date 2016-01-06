class AddNumberToCreditAgreement < ActiveRecord::Migration
  def change
    add_column :credit_agreements, :number, :string, null: true
  end
end
