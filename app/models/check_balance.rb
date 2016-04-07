class CheckBalance < AutoBalance
  def save
    false
  end

  def sum_upto(date)
    return super if expected_deposit == 0
    super + expected_deposit
  end

  private
  def breakpoints
    return super if expected_deposit == 0
    (super + extra_breakpoints).uniq.sort
  end

  def extra_breakpoints
    return [] if start_amount > 0
    [ [credit_agreement.valid_from, date.beginning_of_year].max ]
  end

  def set_date
    self.date ||= Date.today.end_of_year
  end

  def expected_deposit
    credit_agreement.amount - credit_agreement.payments.where(sign: 1).sum(:amount)
  end
end

