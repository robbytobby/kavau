class InterestSpan
  attr_reader :start_date, :end_date, :base_amount, :interest_rate

  def initialize(balance, span)
    @start_date = span.first
    @end_date = span.last
    @base_amount = balance.sum_upto(@start_date)
    @interest_rate = balance.interest_rate
  end

  def date
    @end_date - 1.day
  end

  def amount 
    exact_amount.round(2)
  end

  def interest_days
    (end_date - start_date).to_i
  end

  def days_in_year
    end_date.end_of_year.yday
  end

  def to_partial_path
    'balances/interest_span'
  end

  private
    def exact_amount
      base_amount * rate * interest_days / days_in_year 
    end

    def rate
      interest_rate / 100
    end
end

