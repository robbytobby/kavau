class AddInterestRateToCreditAgreementVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_agreement_versions, :interest_rate, :decimal, precision: 4, scale: 2
  end
end
