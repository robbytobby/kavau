class AddPaymentIdToPdfs < ActiveRecord::Migration
  def change
    add_column :pdfs, :payment_id, :integer, null: true
  end
end
