class CreateCreditAgreementVersions < ActiveRecord::Migration[4.2]
  TEXT_BYTES = 1_073_741_823
  def change
    create_table :credit_agreement_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object,    :limit => TEXT_BYTES
      t.datetime :created_at
      t.date     :valid_from, :null => false
      t.boolean  :interest_rate_changed, :null => false, default: false
    end
    add_index :credit_agreement_versions, [:item_type, :item_id]
  end
end
