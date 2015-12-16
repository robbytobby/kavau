class BalancePdf < ApplicationPdf
  def initialize(balance, pages = :all)
    @balance = balance
    @pages = pages
    @template = get_template
    @pdf_letter = PdfLetter.new(template, self)
    @pdf_balance = PdfBalance.new(@balance, self)
    @interest_certificate = PdfInterestCertificate.new(balance.project_address, [balance], self)
    super @balance.project_address, @balance.creditor
  end
  
  private
  def content
    if @pages == :all
      @pdf_letter.content
      start_new_page
    end
    @pdf_balance.content
    if @pages == :all
      start_new_page
      @interest_certificate.content
    end
  end

  def template
    raise MissingTemplateError.new(BalanceLetter, @balance.date.year) unless @template
    @template
  end

  def get_template
    @template = BalanceLetter.find_by(year: @balance.date.year) || BalanceLetter.find_by(year: nil)
  end

end
