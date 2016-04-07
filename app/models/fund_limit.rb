class FundLimit
  attr_reader :fund, :date

  def initialize(fund, date, excluded: nil)
    @fund = fund
    @date = date
    #@excluded_credit_agreement_id = excluded.id if excluded.is_a?(CreditAgreement)
    #@excluded_payment_id = excluded_payment_id if excluded.is_a?(Deposit)
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
