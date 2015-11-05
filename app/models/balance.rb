class Balance < ActiveRecord::Base
  belongs_to :credit_agreement
  after_initialize :set_date
  before_save :set_amount

  def calculated_amount
    start_amount +
      deposits.sum(:amount) -
      disburses.sum(:amount) + 
      interests
  end

  def amount 
    # FIXME recalculate amount if payment changes
    self[:amount] ||= calculated_amount
  end

  def interests
    base_interest.amount + 
    deposits.to_a.sum{ |d| d.this_years_interest(date).amount } - 
    disburses.to_a.sum{ |d| d.this_years_interest(date).amount }
  end

  def base_interest
    Interest.new(last_years_balance, date)
  end

  def to_interest
    Interest.new(self, date)
  end

  def deposits
    credit_agreement.deposits.this_year_upto(date)
  end

  def disburses
    credit_agreement.disburses.this_year_upto(date)
  end

  def start_amount
    last_years_balance.try(:amount) || 0
  end

  def last_years_balance
    return nil if credit_agreement.payments.until((date - 1.year).end_of_year).none?
    Balance.find_or_create_by(credit_agreement_id: credit_agreement_id, date: (date - 1.year).end_of_year)
  end

  private
    def set_date
      self.date ||= Date.today
    end

    def set_amount
      self.amount = amount
    end

end
