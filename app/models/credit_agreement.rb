class CreditAgreement < ActiveRecord::Base
  strip_attributes 

  #TODO Add notes
  belongs_to :creditor, class_name: 'Address'
  belongs_to :account

  validates_presence_of :amount, :interest_rate, :cancellation_period, :account_id, :creditor_id
  validates_numericality_of :amount, greater_than_or_equal_to: 500
  validates_numericality_of :interest_rate, greater_than_or_equal_to: 0, less_than: 100
  validates_numericality_of :cancellation_period, greater_than_or_equal_to: 3
  validates_inclusion_of :account_id, in: ->(credit_agreement){ Account.project_accounts.map(&:id) }

  def self.funded_credits_sum
    sum(:amount)
  end

  def self.average_rate_of_interest
    return 0 unless funded_credits_sum > 0
    sum("interest_rate * amount") / funded_credits_sum 
  end
end
