class Payment < ActiveRecord::Base
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  belongs_to :credit_agreement

  scope :until, ->(to_date){ where(['date <= ?', to_date]) }
  scope :this_year_upto, ->(to_date){ where(['date >= ?', to_date.beginning_of_year]).where(['date <= ?', to_date]) }

  def self.valid_types
    subclasses.map(&:name)
  end

  def to_partial_path
    "payments/payment"
  end

  def this_years_interest(to_date = nil)
    to_date ||= (Date.today.beginning_of_year > date ? date.end_of_year : Date.today)
    Interest.new(self, to_date)
  end

  private
end
