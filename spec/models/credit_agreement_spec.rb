require 'rails_helper'

RSpec.describe CreditAgreement, type: :model do
  before :each do
    @account_1 = create :project_account
    @account_2 = create :project_account
    @credit_1 = create :credit_agreement, account: @account_1, amount: 1000, interest_rate: '1'
    @credit_2 = create :credit_agreement, account: @account_1, amount: 2000, interest_rate: '2'
    @credit_3 = create :credit_agreement, account: @account_2, amount: 4000, interest_rate: '3'
  end

  it "can average the rate of interest over all project accounts" do
    expect(CreditAgreement.average_rate_of_interest).to be_within(0.001).of(2.428)
  end

  it "can sum of credits over all project agreements" do
    expect(CreditAgreement.funded_credits_sum).to eq(7000)
  end
  
  it "is only valid for project_accounts" do
    @account = create :person_account
    @credit_agreement = build :credit_agreement, account: @account
    expect(@credit_agreement).not_to be_valid
  end
end
