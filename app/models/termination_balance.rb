class TerminationBalance < AutoBalance
  before_save :create_disburse
  after_destroy :delete_disburse, :reopen!

  delegate :reopen!, to: :credit_agreement

  private
  def create_disburse
    Disburse.create(credit_agreement_id: credit_agreement_id, amount: end_amount, date: date)
  end

  def delete_disburse
    credit_agreement.payments.order(created_at: :asc).last.try(:destroy)
  end
end
