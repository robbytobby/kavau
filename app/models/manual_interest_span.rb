class ManualInterestSpan < InterestSpan
  def initialize(balance, span)
    super
    @base_amount = balance.sum_upto(@start_date.beginning_of_year)
    @amount = balance.end_amount - base_amount - balance.deposits.sum(:amount) + balance.disburses.sum(:amount)
  end

  def amount 
    @amount
  end
end

