class Payment < ActiveRecord::Base
  include AsSpreadsheet
  belongs_to :credit_agreement
  has_one :pdf
  delegate :balances, :last_terminated_year, to: :credit_agreement
  delegate :creditor_name, :credit_agreement_number, :account_name, :date, :type, to: :presented, prefix: true
  
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  validates_numericality_of :amount, greater_than: 0
  validate :not_in_the_future, :year_not_terminated

  scope :younger_than_inc, ->(to_date){ where(['date <= ?', to_date]) }
  scope :older_than, ->(from_date){ where(['date > ?', from_date]) }
  scope :this_year_upto, ->(to_date){ younger_than_inc(to_date).older_than(to_date.beginning_of_year.prev_day) }

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
  def spreadsheet_values
    [:id, :presented_date, :presented_type, :presented_creditor_name, :presented_credit_agreement_number, :presented_account_name, :amount]
  end

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
