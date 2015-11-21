class AddTerminatedAtToCreditAgreement < ActiveRecord::Migration
  def change
    add_column :credit_agreements, :terminated_at, :date, null: true
  end
end
