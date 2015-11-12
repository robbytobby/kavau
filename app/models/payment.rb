class Payment < ActiveRecord::Base
  belongs_to :credit_agreement
  delegate :balances, to: :credit_agreement
  
  validates_presence_of :amount, :type, :date, :credit_agreement_id
  validates_numericality_of :amount, greater_than: 0

  scope :younger_than, ->(to_date){ where(['date <= ?', to_date]) }
  scope :older_than, ->(from_date){ where(['date >= ?', from_date]) }
  scope :this_year_upto, ->(to_date){ younger_than(to_date).older_than(to_date.beginning_of_year) }

  after_save :update_balances
  after_destroy :update_balances

  def self.valid_types
    subclasses.map(&:name)
  end

  def to_partial_path
    "payments/payment"
  end

  private
    def update_balances
      balances.older_than(date).each(&:update_end_amount!)
    end
end
