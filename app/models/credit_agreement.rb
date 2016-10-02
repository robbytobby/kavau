class CreditAgreement < ActiveRecord::Base
  include ActiveModel::Dirty

  strip_attributes
  #has_paper_trail class_name: 'CreditAgreementVersion', meta: { valid_from: :valid_from, valid_until: :version_valid_until, interest_rate_changed: :interest_rate_changed? , interest_rate: :interest_rate}, ignore: [:created_at, :updated_at, :id, :creditor_id]
  has_paper_trail class_name: 'CreditAgreementVersion', ignore: [:created_at, :updated_at, :id, :creditor_id]

  # TODO: Add notes
  belongs_to :creditor, class_name: 'Address'
  belongs_to :account
  has_many :payments, -> { order 'date asc' }, dependent: :restrict_with_exception
  has_many :balances, -> { order 'date asc' }, dependent: :destroy
  has_many :auto_balances, -> { order 'date asc' }
  has_one :termination_balance

  delegate :belongs_to_project?, to: :account, prefix: true
  delegate :last_terminated_year, :year_terminated?, to: :creditor

  validates_presence_of :amount, :interest_rate, :cancellation_period, :account_id, :creditor_id, :valid_from
  validates_numericality_of :amount, :cancellation_period, greater_than: 0
  validates_uniqueness_of :number, allow_blank: true
  validate :account_valid_for_credit_agreement?, :termination_date_after_payments, :fund_exists?, :after_fund_issuing, :fund_limit_fits?

  after_save :terminate, :update_balances
  before_validation :set_number
  validates_date :valid_from, on: :update

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

  def check_balance(date = Date.today.end_of_year)
    CheckBalance.new(credit_agreement: self, date: date)
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

  def issued_at
    return valid_from if payments.none?
    payments.first.date
  end

  def fund
    return unless interest_rate && account
    Fund.find_by(interest_rate: interest_rate, project_address: account.address)
  end

  def is_regulated?
    return false if valid_from.blank?
    valid_from >= Fund.regulated_from
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

    def fund_exists?
      return unless is_regulated?
      errors.add(:interest_rate, :no_fund) unless fund
    end

    def after_fund_issuing
      return unless is_regulated? && fund
      errors.add(:valid_from, :before_fund_isssued, date: fund.issued_at) if valid_from < fund.issued_at
    end

    def fund_limit_fits?
      return unless is_regulated? && fund && amount
      errors.add(*fund.error_message_for_credit_agreement(self)) unless fund.fits(self)
    end

    def terminate
      return unless terminated_at_changed?
      return if terminated_at_changed?(to: nil)
      CreditAgreementTerminator.new(self).terminate
    end

    def update_balances
      return unless interest_rate_changed?
      BalanceUpdater.new(self).run
    end

    def set_number
      return unless account_id
      return unless number.blank?
      self.number = last_used_number.try(:next) || "#{account_id}0001"
    end

    def last_used_number
      CreditAgreement.where(account_id: account_id).where.not(number: nil).where.not(id: id).order(number: :desc).first.try(:number)
    end

    def at(date)
      versions.at(date).try(:reify) || self
    end
end
