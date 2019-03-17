class AddValidUntilToCreditAgreementVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_agreement_versions, :valid_until, :date
  end
end
