class TerminationPdf < CompositePdf
  def initialize(credit_agreement, letter)
    @letter = letter
    @credit_agreement = credit_agreement
    @creditor = @credit_agreement.creditor
    @balance = @credit_agreement.termination_balance
    super
  end

  private
  def build_parts
    covering_letter
    balance_page(@balance)
    interest_certificate_page([@balance])
  end
end
