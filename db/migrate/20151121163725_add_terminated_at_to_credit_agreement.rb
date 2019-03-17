class AddTerminatedAtToCreditAgreement < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_agreements, :terminated_at, :date, null: true
  end
end
