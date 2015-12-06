class BalancePdf < ApplicationPdf
  def initialize(balance)
    @balance = balance
    @template = get_template
    @pdf_letter = PdfLetter.new(template, self)
    @pdf_balance = PdfBalance.new(@balance, self)
    @interest_certificate = PdfInterestCertificate.new(balance.project_address, [balance], self)
    super @balance.project_address, @balance.creditor
  end
  
  private
  def content
    @pdf_letter.content
    start_new_page
    @pdf_balance.content
    start_new_page
    @interest_certificate.content
  end

  def template
    raise MissingTemplateError.new(BalanceLetter, @balance.date.year) unless @template
    @template
  end

  def get_template
    @template = BalanceLetter.find_by(year: @balance.date.year) || BalanceLetter.find_by(year: nil)
  end

end
