class YearlyBalancePdf < ApplicationPdf
  def initialize(creditor, letter)
    @letter = letter
    @balances = creditor.balances.where(date: Date.new(letter.year).end_of_year)
    @template = get_template
    @pdf_letter = PdfLetter.new(template, self)
    super ProjectAddress.where(legal_form: 'registered_society').first, creditor
  end

  private
  def content
    @pdf_letter.content
    balances_pages
    interest_certificate_pages
  end

  def balances_pages
    @balances.each do |balance|
      start_new_page
      PdfBalance.new(balance, self).content
    end
  end

  def interest_certificate_pages
    @balances.group_by(&:project_address).each do |project_address, balances|
      next if balances.all?{|b| b.credit_agreement.interest_rate == 0 }
      start_new_page
      PdfInterestCertificate.new(project_address, balances, self).content
    end
  end

  def template
    raise MissingTemplateError.new(BalanceLetter, @letter.year) unless @template
    @template
  end

  def get_template
    @template = BalanceLetter.find_by(year: @letter.year) || BalanceLetter.find_by(year: nil)
  end
end
