class AddInterestRateToCreditAgreementVersions < ActiveRecord::Migration
  def change
    add_column :credit_agreement_versions, :interest_rate, :decimal, precision: 4, scale: 2
  end
end
