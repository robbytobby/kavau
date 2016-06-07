class OneYearAmountLimit < FundLimit
  include ActionView::Helpers::NumberHelper
  
  def available
    dates_to_check.map{|check_date| @check_date = check_date; available_one_year_amount}.min
  end

  def fits(record)
    @for = record
    available >= check_amount
  end

  def check_amount
    set_exclude
    return @for.amount if @for.new_record? || !@for.amount_changed?
    @for.amount - @for.amount_was
  end

  def error_message(record)
    @for = record
    set_exclude
    [:amount, :to_much, max: number_to_currency(maximium)]
  end

  private
  def set_exclude
    return if @for.new_record? || @for.amount_changed?
    @exclude = @for
  end

  def maximium
    return available + @for.amount_was if @for.persisted? && @for.amount_changed?
    available
  end

  def dates_to_check
    ([@date, end_of_year] + deposits_after(@date).pluck(:date)).uniq
  end

  def end_of_year
    return @date.next_year if @date == @date.end_of_year
    @date.end_of_year
  end

  def available_one_year_amount
    return one_year_limit - used_one_year_amount if @check_date < @date.end_of_year
    max_anticipating_interests(used_one_year_amount)
  end

  def max_anticipating_interests(allready_used = 0)
    ReverseInterestCalculator.new(
      base_amount: (one_year_limit - allready_used),
      fund: @fund,
      start_date: @date,
      end_date: @check_date > @date ? end_of_year : @date.end_of_year
    ).maximum_credit
  end

  def used_one_year_amount
    one_years_deposits + one_years_interests
  end

  def one_years_deposits
    deposits_after(@check_date.prev_year).before_inc(@check_date).sum(:amount) + planned_deposits
  end

  def planned_deposits
    credit_agreements.sum(:amount) - Deposit.where(credit_agreement_id: credit_agreements.pluck(:id)).sum(:amount)
  end

  def credit_agreements_without_payment
    credit_agreements.includes(:payments).references(:payments).where(payments: {id: nil})
  end

  def one_years_interests
    credit_agreements.map{ |credit| credit.check_balance(balance_date) }.sum(&:interests_sum)
  end
  
  def balance_date
    return @check_date if @check_date == @check_date.end_of_year
    @check_date.prev_year.end_of_year
  end

  def deposits
    Deposit.for_fund(@fund).where( Deposit.arel_table[:date].gteq(Fund.regulated_from ))
  end

  def deposits_after(date)
    deposits.after(date)
  end

  def one_year_limit 
    100000 
  end
end
