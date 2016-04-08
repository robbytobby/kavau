class FundLimit
  attr_reader :fund, :date

  def initialize(fund, date)
    @fund = fund
    @date = date
  end

  def amount
    nil
  end

  private
  def credit_agreements
    fund.credit_agreements.where.not(id: excluded_credit_agreement_id)
  end

  def excluded_credit_agreement_id
    return unless @exclude.is_a?(CreditAgreement)
    @exclude.id
  end
end
