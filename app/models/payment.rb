class Payment < ActiveRecord::Base
  belongs_to :credit_agreement, touch: true
  delegate :balances, to: :credit_agreement
  
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  validates_numericality_of :amount, greater_than: 0
  validate :not_in_the_future, :not_before_last_balance_pdf

  scope :younger_than_inc, ->(to_date){ where(['date <= ?', to_date]) }
  scope :older_than, ->(from_date){ where(['date > ?', from_date]) }
  scope :this_year_upto, ->(to_date){ younger_than_inc(to_date).older_than(to_date.beginning_of_year.prev_day) }

  def self.valid_types
    subclasses.map(&:name)
  end

  def to_partial_path
    "payments/payment"
  end

  private
  def not_in_the_future
    return if date <= Date.today
    errors.add(:date, :in_the_future)
  end

  def not_before_last_balance_pdf
    return if last_balance_pdf_year.blank?
    return if date > Date.new(last_balance_pdf_year).end_of_year
    errors.add(:date, :allready_closed, year: last_balance_pdf_year)
  end

  def last_balance_pdf_year
    credit_agreement.creditor.pdfs.map(&:letter).select{|l| l.balance_letter?}.map(&:year).max
  end
end
