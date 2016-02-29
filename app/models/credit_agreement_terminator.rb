class CreditAgreementTerminator

  def initialize(credit_agreement)
    @credit_agreement = credit_agreement
    @creditor = @credit_agreement.creditor
    @termination_date = @credit_agreement.terminated_at
  end

  def terminate
    @balance = @credit_agreement.create_termination_balance(date: @termination_date)
    create_disburse
    create_pdf
    delete_stale_balances
  end

  def reopen
    @credit_agreement.update(terminated_at: nil)
    delete_disburse
    delete_pdf
    BalanceUpdater.new(@credit_agreement).run
  end

  private
  def create_pdf
    raise MissingLetterTemplateError.new(TerminationLetter) unless TerminationLetter.exists?
    Pdf.create!(letter: TerminationLetter.first, creditor: @creditor, credit_agreement: @credit_agreement)
  end

  def delete_stale_balances
    @credit_agreement.balances.older_than(@termination_date).destroy_all
  end

  def create_disburse
    Disburse.create(credit_agreement_id: @credit_agreement.id, amount: @balance.end_amount, date: @termination_date)
  end

  def delete_disburse
    @credit_agreement.payments.where(type: 'Disburse', date: @termination_date).order(created_at: :asc).last.try(:destroy)
  end

  def delete_pdf
    Pdf.find_by(letter: TerminationLetter.first, creditor: @creditor, credit_agreement: @credit_agreement).destroy
  end
end
