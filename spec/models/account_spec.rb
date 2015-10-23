require 'rails_helper'

RSpec.describe Account, type: :model do
  before :each do
      @account_1 = create :project_account
      @account_2 = create :project_account
      @credit_1 = create :credit_agreement, account: @account_1, amount: 1000, interest_rate: '1'
      @credit_2 = create :credit_agreement, account: @account_1, amount: 2000, interest_rate: '2'
      @credit_3 = create :credit_agreement, account: @account_2, amount: 4000, interest_rate: '3'
  end

  context "the sum of amount of credit_agreements" do
    it "funded_credits_sum" do
      expect(@account_1.funded_credits_sum).to eq(3000)
      expect(@account_2.funded_credits_sum).to eq(4000)
    end

    it "average_rate_of_interest" do
      expect(@account_1.average_rate_of_interest).to be_within(0.001).of(1.667)
      expect(@account_2.average_rate_of_interest).to eq(3.0)
    end
  end
end
