class Payment < ApplicationRecord
  include BelongsToFundViaCreditAgreement
  include DateScopes

  belongs_to :credit_agreement
  has_one :pdf, dependent: :destroy
  delegate :balances, :last_terminated_year, to: :credit_agreement
  
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  validates_numericality_of :amount, greater_than: 0
  validate :not_in_the_future, :year_not_terminated

  after_save :update_balances
  after_destroy :update_balances

  ransacker :year, formatter: lambda{ |v| v.gsub!(/.*(\d{4}).*/,'\1') } do
    Arel.sql('extract(year from date)')
  end

  def self.valid_types
    subclasses.map(&:name)
  end

  def to_partial_path
    "payments/payment"
  end

  def year_terminated?
    return false unless date
    credit_agreement.year_terminated?(date.year)
  end

  private
  def update_balances
    BalanceUpdater.new(credit_agreement).run
  end

  def not_in_the_future
    return if date <= Date.today
    errors.add(:date, :in_the_future)
  end

  def year_not_terminated
    return unless first_valid_date
    return if date >= first_valid_date
    errors.add(:date, :allready_closed, year: last_terminated_year)
  end

  def first_valid_date
    return unless last_terminated_year
    Date.new(last_terminated_year).end_of_year.next_day
  end
end
