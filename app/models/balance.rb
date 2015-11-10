class Balance < ActiveRecord::Base
  belongs_to :credit_agreement
  after_initialize :set_date
  before_save :set_amount

  delegate :interest_rate, to: :credit_agreement

  scope :older_than, ->(from_date){ where(['date >= ?', from_date]) }
  
  alias_method :update_end_amount!, :save

  def self.interest_sum
    all.to_a.sum{| b| b.interests_sum }
  end

  def interests_sum
    @interests_sum ||= interest_spans.sum(&:amount)
  end

  def interest_spans
    breakpoints.each_cons(2).map{ |pair| InterestSpan.new(self, pair) }
  end

  def start_amount
    @start_amount ||= last_years_balance.end_amount
  end

  def end_amount 
    self[:end_amount] ||= calculated_end_amount
  end

  def sum_upto(to_date)
    start_amount +
      deposits.younger_than(to_date).sum(:amount) -
      disburses.younger_than(to_date).sum(:amount)
  end

  private
    def last_years_balance
      return NullBalance.new if past_years_payments.none?
      Balance.find_or_create_by(
        credit_agreement_id: credit_agreement_id, 
        date: end_of_last_year)
    end

    def set_date
      self.date ||= Date.today
    end

    def set_amount
      self.end_amount = calculated_end_amount
    end

    def past_years_payments
      credit_agreement.payments.younger_than(end_of_last_year)
    end

    def deposits
      credit_agreement.deposits.this_year_upto(date)
    end

    def disburses
      credit_agreement.disburses.this_year_upto(date)
    end

    def payments
      credit_agreement.payments.this_year_upto(date)
    end

    def calculated_end_amount
      sum_upto(date) + interests_sum
    end

    def breakpoints
      [end_of_last_year] + payments.map(&:date) + [date]
    end

    def end_of_last_year
      date.prev_year.end_of_year
    end

  class NullBalance
    def end_amount
      0
    end
  end
end
