class FundLimit
  delegate :credit_agreements, to: :fund
  attr_reader :fund, :date

  def initialize(fund, date)
    @fund = fund
    @date = date
  end

  def amount
    nil
  end
end
