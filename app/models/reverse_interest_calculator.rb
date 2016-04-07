class ReverseInterestCalculator < InterestSpan
  def initialize(base_amount:, fund:, start_date:, end_date:)
    @base_amount = base_amount
    @interest_rate = fund.interest_rate
    @end_date = end_date
    @start_date = start_date
  end

  def maximum_credit
    (base_amount / devider).floor_to(0.01)
  end

  private
  def devider
    1 + rate * interest_days / days_in_year 
  end
end
