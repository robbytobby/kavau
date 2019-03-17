class AddObjectChangesToCreditAgreementVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :credit_agreement_versions, :object_changes, :text
  end
end
