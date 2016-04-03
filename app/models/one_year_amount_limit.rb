class OneYearAmountLimit < FundLimit
  include ActionView::Helpers::NumberHelper
  
  def available
    dates_to_check.map{|check_date| @check_date = check_date; available_one_year_amount}.min
  end

  def fits(amount)
    available >= amount
  end

  def error_message
    [:amount, :to_much, max: number_to_currency(available)]
  end

  private
  def dates_to_check
    [@date, @date.end_of_year] + deposits_after(@date).pluck(:date)
  end

  def available_one_year_amount
    return one_year_limit - used_one_year_amount if @check_date < Date.today.end_of_year
    max_anticipating_interests(used_one_year_amount)
  end

  def max_anticipating_interests(allready_used = 0)
    ReverseInterestCalculator.new(
      base_amount: (one_year_limit - allready_used),
      fund: @fund,
      for_date: @date
    ).maximum_credit
  end

  def used_one_year_amount
    one_years_deposits + one_years_interests
  end

  def one_years_deposits
    deposits_after(@check_date.prev_year).before_inc(@check_date).sum(:amount) + 
      credit_agreements_without_payment.sum(:amount)
  end

  def credit_agreements_without_payment
    credit_agreements.includes(:payments).references(:payments).where(payments: {id: nil})
  end

  def one_years_interests
    if balance_date.past?
      Balance.for_fund(@fund).where(date: balance_date).sum(:interests_sum)
    else
      credit_agreements.map{ |credit| credit.check_balance(balance_date) }.sum(&:interests_sum)
    end
  end

  def balance_date
    return @check_date if @check_date == @check_date.end_of_year
    @check_date.prev_year.end_of_year
  end

  def deposits
    Deposit.for_fund(@fund)
  end

  def deposits_after(date)
    deposits.after(date)
  end

  def one_year_limit 
    100000 
  end
end
