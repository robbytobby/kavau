class RemoveFieldsFromCreditAgreementVesions < ActiveRecord::Migration
  def change
    incompatible = CreditAgreementVersion.where(interest_rate_changed: true).where.not(event: 'create').any?
    raise "There are CreditAgreementVersions with changes in interest rate, this is now forbidden. You have to resolve this Problem manually" if incompatible
    remove_column :credit_agreement_versions, :interest_rate_changed, :boolean
    remove_column :credit_agreement_versions, :interest_rate, :decimal
    remove_column :credit_agreement_versions, :valid_from, :date
    remove_column :credit_agreement_versions, :valid_until, :date
  end
end
