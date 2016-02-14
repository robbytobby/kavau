class YearlyBalancePdf < CompositePdf
  def initialize(creditor, letter)
    @letter = letter
    @creditor = creditor
    @balances = creditor.balances.where(date: Date.new(@letter.year).end_of_year)
    super
  end

  private 
  def build_parts
    covering_letter
    @balances.each{ |b| balance_page(b) }
    @balances.group_by(&:project_address).each{ |project_address, balances| interest_certificate_page(balances) }
  end
end
