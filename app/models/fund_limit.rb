class FundLimit
  def initialize(fund, date)
    @fund = fund
    @date = date
  end

  def amount
    nil
  end

  private
  def same_interst_rate_credit_agreements
    CreditAgreement.where(interest_rate: @fund.interest_rate)
  end
end
