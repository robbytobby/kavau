class NumberOfSharesLimit < FundLimit
  def available 
    max_shares - number_of_issued_shares
  end

  private
  def number_of_issued_shares
    credit_agreements.count
  end

  def max_shares
    20
  end
end
