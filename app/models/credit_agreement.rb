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

  attr_accessor :payment_amount, :payment_type

  def self.funded_credits_sum
    sum(:amount)
  end

  def self.average_rate_of_interest
    return 0 unless funded_credits_sum > 0
    sum('interest_rate * amount') / funded_credits_sum
  end

  def balance_items
    create_missing_balances if payments.any?
    balances.build
    (payments + balances).sort_by(&:date)
  end

  private
    def account_valid_for_credit_agreement?
      return if account_belongs_to_project?
      errors.add(:base, :only_project_accounts_valid)
    end

    def create_missing_balances
      (year_of_first_payment...this_year).each do |year|
        balances.find_or_create_by(date: Date.new(year, 12, 31))
      end
    end

    def year_of_first_payment
      payments.first.date.year
    end

    def this_year
      Date.today.year
    end
end
