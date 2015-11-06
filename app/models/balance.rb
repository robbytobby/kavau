class Balance < ActiveRecord::Base
  belongs_to :credit_agreement
  after_initialize :set_date
  before_save :set_amount

  def self.interest_sum
    all.to_a.sum{| b| b.interest_from_start_amount.amount }
  end

  def end_amount 
    # FIXME recalculate amount if payment changes
    self[:end_amount] ||= calculated_end_amount
  end

  def interest_from_start_amount
    BalanceInterest.new(last_years_balance, date)
  end

  def to_interest
    BalanceInterest.new(self, date)
  end

  def start_amount
    last_years_balance.try(:end_amount) || 0
  end

  def last_years_balance
    return nil if past_years_payments.none?
    Balance.find_or_create_by(credit_agreement_id: credit_agreement_id, date: end_of_last_year)
  end

  private
    def set_date
      self.date ||= Date.today
    end

    def set_amount
      self.end_amount = end_amount
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

    def interests
      [interest_from_start_amount] + 
        deposits.map{ |d| d.interest(date) } + 
        disburses.map{ |d| d.interest(date) }
    end

    def calculated_end_amount
      start_amount +
        deposits.sum(:amount) -
        disburses.sum(:amount) + 
        interests.sum(&:amount)
    end

    def end_of_last_year
      (date - 1.year).end_of_year
    end
end
