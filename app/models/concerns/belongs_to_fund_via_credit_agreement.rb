require 'active_support/concern'

module BelongsToFundViaCreditAgreement
  extend ActiveSupport::Concern

  included do
    scope :for_fund, ->(fund){ joins(:credit_agreement).where(credit_agreements: {interest_rate: fund.interest_rate}) }
  end
end
