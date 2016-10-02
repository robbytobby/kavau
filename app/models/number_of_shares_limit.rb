class NumberOfSharesLimit < FundLimit
  def available 
    max_shares - number_of_issued_shares
  end

  def fits(record)
    return true if record.persisted? && !record.interest_rate_changed?
    available > 0
  end

  def error_message(record)
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
