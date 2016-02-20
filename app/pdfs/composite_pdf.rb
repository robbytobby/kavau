class CompositePdf
  def initialize(*sugar)
    @combined = CombinePDF.new
    build_parts
  end

  def rendered
    @combined.to_pdf
  end

  private
  def balance_page(balance)
    @combined << parse(BalancePdf.new(balance))
  end

  def interest_certificate_page(balances)
    return if balances.all?{|b| b.credit_agreement.interest_rate == 0 }
    @combined << parse(InterestCertificatePdf.new(balances))
  end

  def covering_letter
    @combined << parse(LetterPdf.new(@creditor, @letter))
  end

  def parse(page)
    CombinePDF.parse page.rendered
  end
end
