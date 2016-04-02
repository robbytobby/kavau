require 'active_support/concern'

module BelongsToFundViaCreditAgreement
  extend ActiveSupport::Concern

  included do
    scope :for_fund, ->(fund){ where(credit_agreement_id: fund.credit_agreements.pluck(:id)) }
  end
end
