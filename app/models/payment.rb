class Payment < ActiveRecord::Base
  belongs_to :credit_agreement, touch: true
  delegate :balances, to: :credit_agreement
  
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  validates_numericality_of :amount, greater_than: 0
  validate :not_in_the_future

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
end
