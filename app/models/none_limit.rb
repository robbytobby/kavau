class NoneLimit < FundLimit
  def credit_agreements
    CreditAgreement.none
  end

end
