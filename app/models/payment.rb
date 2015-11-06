class Payment < ActiveRecord::Base
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  belongs_to :credit_agreement
  delegate :balances, to: :credit_agreement

  scope :younger_than, ->(to_date){ where(['date <= ?', to_date]) }
  scope :older_than, ->(from_date){ where(['date >= ?', from_date]) }
  scope :this_year_upto, ->(to_date){ younger_than(to_date).older_than(to_date.beginning_of_year) }

  after_save :update_balances

  def self.valid_types
    subclasses.map(&:name)
  end

  def self.interest_sum
    all.to_a.sum{ |p| p.interest.amount }
  end

  def to_partial_path
    "payments/payment"
  end

  def interest(to_date = nil)
    to_date ||= (from_last_year? ? date.end_of_year : Date.today)
    PaymentInterest.new(self, to_date)
  end

  private
    def update_balances
      balances.older_than(date).each(&:save)
    end

    def from_last_year?
      Date.today.beginning_of_year > date
    end
end
