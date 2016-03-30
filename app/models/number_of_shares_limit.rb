class NumberOfSharesLimit < FundLimit
  def available 
    max_shares - number_of_issued_shares
  end

  private
  def credit_agreements
    #TODO: Altfallregelung
    same_interst_rate_credit_agreements.select{|credit| credit.issued_at >= @fund.issued_at }
  end
  
  def number_of_issued_shares
    credit_agreements.count
  end

  def max_shares
    20
  end
end
