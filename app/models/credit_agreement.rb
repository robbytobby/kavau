class CreditAgreement < ActiveRecord::Base
  include ActiveModel::Dirty
  include AsCsv
  strip_attributes

  # TODO: Add notes
  belongs_to :creditor, class_name: 'Address'
  belongs_to :account
  has_many :payments, -> { order 'date asc' }, dependent: :restrict_with_exception
  has_many :balances, -> { order 'date asc' }, dependent: :destroy
  has_many :auto_balances, -> { order 'date asc' }
  has_one :termination_balance

  delegate :belongs_to_project?, to: :account, prefix: true
  delegate :last_terminated_year, :year_terminated?, to: :creditor

  validates_presence_of :amount, :interest_rate, :cancellation_period, :account_id, :creditor_id
  validates_numericality_of :amount, greater_than_or_equal_to: 0
  validates_numericality_of :interest_rate, greater_than_or_equal_to: 0, less_than: 100
  validates_numericality_of :cancellation_period, greater_than_or_equal_to: 0
  validates_uniqueness_of :number, allow_blank: true
  validate :account_valid_for_credit_agreement?, :termination_date_after_payments

  after_save :terminate
  before_validation :set_number

  def self.funded_credits_sum
    sum(:amount)
  end

  def self.average_rate_of_interest
    return 0 unless funded_credits_sum > 0
    sum('interest_rate * amount') / funded_credits_sum
  end

  def todays_total
    todays_balance.end_amount
  end

  def total_interest
    balances.interest_sum + todays_balance.interests_sum
  end

  def todays_balance
    auto_balances.build
  end

  def active?
    !terminated? && payments.any?
  end

  def terminated?
    return false if errors[:terminated_at].any?
    !terminated_at.blank?
  end

  def self.csv_columns
    [:id, :number, :amount, :interest_rate, :cancellation_period, :creditor_name, :creditor_id, :account_name, :account_id, :terminated_at]
  end

  private
    def account_valid_for_credit_agreement?
      return unless account
      return if account_belongs_to_project?
      errors.add(:base, :only_project_accounts_valid)
    end

    def termination_date_after_payments
      return if terminated_at.blank? || payments.none?
      return if terminated_at >= payments.last.date
      errors.add(:terminated_at, :before_last_payment)
    end

    def terminate
      return unless terminated_at_changed?
      return if terminated_at_changed?(to: nil)
      CreditAgreementTerminator.new(self).terminate
    end

    def set_number
      return unless account_id
      return unless number.blank?
      self.number = last_used_number.try(:next) || "#{account_id}0001"
    end

    def last_used_number
      CreditAgreement.where(account_id: account_id).where.not(number: nil).order(number: :desc).first.try(:number)
    end
end

class NullPayment
  def date
    Date.today
  end
end
