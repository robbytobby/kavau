class AddValidUntilToCreditAgreementVersions < ActiveRecord::Migration
  def change
    add_column :credit_agreement_versions, :valid_until, :date
  end
end
