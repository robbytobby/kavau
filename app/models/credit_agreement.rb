class CreditAgreement < ActiveRecord::Base
  strip_attributes

  # TODO: Add notes
  belongs_to :creditor, class_name: 'Address'
  belongs_to :account
  delegate :belongs_to_project?, to: :account, prefix: true

  has_many :payments, -> { order 'date asc' }, dependent: :restrict_with_exception
  has_many :deposits, -> { order 'date asc' }
  has_many :disburses, -> { order 'date asc' }
  has_many :balances

  validates_presence_of :amount, :interest_rate, :cancellation_period, :account_id, :creditor_id
  validates_numericality_of :amount, greater_than_or_equal_to: 500
  validates_numericality_of :interest_rate, greater_than_or_equal_to: 0, less_than: 100
  validates_numericality_of :cancellation_period, greater_than_or_equal_to: 3
  validate :account_valid_for_credit_agreement?

  after_touch :create_missing_balances, :delete_unnecessary_balances, :update_balances
  attr_accessor :payment_amount, :payment_type

  def self.funded_credits_sum
    sum(:amount)
  end

  def self.average_rate_of_interest
    return 0 unless funded_credits_sum > 0
    sum('interest_rate * amount') / funded_credits_sum
  end

  def balance_items
    todays_balance
    (payments + balances + interest_spans).sort_by(&:date)
  end

  def todays_total
    todays_balance.end_amount
  end

  def total_interest
    balances.interest_sum + todays_balance.interests_sum
  end

  private
    def interest_spans
      (balances.automatic + [todays_balance]).map(&:interest_spans).flatten
    end

    def account_valid_for_credit_agreement?
      return if account_belongs_to_project?
      errors.add(:base, :only_project_accounts_valid)
    end

    def update_balances
      balances.each(&:update_end_amount!)
    end

    def delete_unnecessary_balances
      balances.younger_than(date_of_first_payment).destroy_all
    end

    def create_missing_balances
      (obligatory_balances_dates - balances_dates).each do |balance_date|
        balances.create(date: balance_date)
      end
    end

    def balances_dates
      balances.pluck(:date)
    end

    def obligatory_balances_dates
      (date_of_first_payment.year...this_year).map{ |y| Date.new(y, 12, 31) }
    end

    def todays_balance
      balances.build
    end

    def date_of_first_payment
      (payments.first || NullPayment.new).date
    end

    def this_year
      Date.today.year
    end

  class NullPayment
    def date
      Date.today
    end
  end
end

