class CreditAgreement < ActiveRecord::Base
  #TODO Add notes
  belongs_to :creditor
  belongs_to :account

  validates_presence_of :amount, :interest_rate, :cancellation_period, :account_id, :creditor_id
end
