class Payment < ActiveRecord::Base
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  belongs_to :credit_agreement

  scope :until, ->(to_date){ where(['date <= ?', to_date]) }

  def self.valid_types
    subclasses.map(&:name)
  end

  def to_partial_path
    "payments/payment"
  end

  private
    def days_in_year(year)
      Date.new(year).end_of_year.yday
    end
end
