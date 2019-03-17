class AddPaymentIdToPdfs < ActiveRecord::Migration[4.2]
  def change
    add_column :pdfs, :payment_id, :integer, null: true
  end
end
