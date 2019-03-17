class AddNumberToCreditAgreement < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_agreements, :number, :string, null: true
  end
end
