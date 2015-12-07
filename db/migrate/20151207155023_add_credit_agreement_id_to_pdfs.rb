class AddCreditAgreementIdToPdfs < ActiveRecord::Migration
  def change
    add_column :pdfs, :credit_agreement_id, :integer
  end
end
