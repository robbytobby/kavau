class SetValidFromForCreditAgreements < ActiveRecord::Migration
  def up
    CreditAgreement.paper_trail_off!
    CreditAgreement.all.each do |c|
      valid_from ||= (c.payments.first.try(:date) || c.created_at.to_date)
      c.update_column(:valid_from, valid_from)
    end
    CreditAgreement.paper_trail_on!
  end

  def down
  end
end
