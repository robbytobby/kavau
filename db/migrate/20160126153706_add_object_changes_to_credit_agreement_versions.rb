class AddObjectChangesToCreditAgreementVersions < ActiveRecord::Migration
  def change
    add_column :credit_agreement_versions, :object_changes, :text
  end
end
