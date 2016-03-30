class CheckBalance < AutoBalance
  def save
    false
  end

  def sum_upto(date)
    return credit_agreement.amount if credit_agreement.payments.none?
    super
  end

  private
  def breakpoints
    return [[credit_agreement.valid_from, date.beginning_of_year].max, date] if credit_agreement.payments.none?
    super
  end

  def set_date
    self.date ||= Date.today.end_of_year
  end
end

