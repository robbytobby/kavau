class AddValidFromToCreditAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_agreements, :valid_from, :date
  end
end
