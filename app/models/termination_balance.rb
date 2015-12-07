class TerminationBalance < AutoBalance
  before_save :create_disburse
  after_destroy :delete_disburse, :reopen!
  after_create :create_termination_pdf

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
  #destroy pdf on destroy

end
