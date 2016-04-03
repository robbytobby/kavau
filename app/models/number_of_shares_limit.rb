class NumberOfSharesLimit < FundLimit
  def available 
    max_shares - number_of_issued_shares
  end

  def fits(*sugar)
    available > 0
  end

  def error_message
    [:interest_rate, :to_many]
  end

  private
  def number_of_issued_shares
    credit_agreements.count
  end

  def max_shares
    20
  end
end
