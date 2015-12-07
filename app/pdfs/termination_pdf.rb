class TerminationPdf < ApplicationPdf
  def initialize(credit_agreement, letter)
    @letter = letter
    @credit_agreement = credit_agreement
    @balance = @credit_agreement.termination_balance
    @pdf_letter = PdfLetter.new(@letter, self)
    super @balance.project_address, @credit_agreement.creditor
  end

  def content
    @pdf_letter.content
    start_new_page
    PdfBalance.new(@balance, self).content
    start_new_page
    PdfInterestCertificate.new(@balance.project_address, [@balance], self).content
  end
end
