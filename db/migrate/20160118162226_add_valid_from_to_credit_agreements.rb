class AddValidFromToCreditAgreements < ActiveRecord::Migration
  def change
    add_column :credit_agreements, :valid_from, :date
  end
end
