class TerminationBalance < AutoBalance
  before_save :create_disburse
  after_destroy :delete_disburse, :delete_pdf, :reopen!
  after_create :create_termination_pdf, :delete_older_siblings

  delegate :reopen!, to: :credit_agreement

  private
  def create_disburse
    Disburse.create(credit_agreement_id: credit_agreement_id, amount: end_amount, date: date)
  end

  def delete_disburse
    credit_agreement.payments.where(type: 'Disburse', date: date).order(created_at: :asc).last.try(:destroy)
  end

  def create_termination_pdf
    raise MissingTemplateError.new(TerminationLetter) unless TerminationLetter.exists?
    Pdf.create!(letter: TerminationLetter.first, creditor: creditor, credit_agreement: credit_agreement)
  end

  def delete_pdf
    Pdf.find_by(letter: TerminationLetter.first, creditor: creditor, credit_agreement: credit_agreement).destroy
  end

  def delete_older_siblings
    credit_agreement.balances.older_than(self.date).destroy_all
  end
end
