class SetValidFromForCreditAgreements < ActiveRecord::Migration[4.2]
  def up
    PaperTrail.enabled = false
    CreditAgreement.all.each do |c|
      valid_from ||= (c.payments.first.try(:date) || c.created_at.to_date)
      c.update_column(:valid_from, valid_from)
    end
    PaperTrail.enabled = true
  end

  def down
  end
end
