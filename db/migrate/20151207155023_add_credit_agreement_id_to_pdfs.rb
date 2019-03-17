class AddCreditAgreementIdToPdfs < ActiveRecord::Migration[4.2]
  def change
    add_column :pdfs, :credit_agreement_id, :integer
  end
end
