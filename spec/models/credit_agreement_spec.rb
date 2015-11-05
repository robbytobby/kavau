require 'rails_helper'

RSpec.describe CreditAgreement, type: :model do
  describe "Calculations" do
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
  end
  
  it "is only valid for project_accounts" do
    @account = create :person_account
    @credit_agreement = build :credit_agreement, account: @account
    expect(@credit_agreement).not_to be_valid
  end

  describe "balance_items" do
    before(:each){ @credit_agreement = create :credit_agreement }
    it "contain all associated deposits" do
      @deposit = create :deposit, credit_agreement: @credit_agreement
      expect(@credit_agreement.balance_items).to include(@deposit)
    end

    it "does not contain deposits for other credit agreements" do
      @deposit = create :deposit
      expect(@credit_agreement.balance_items).not_to include(@deposit)
    end

    it "contain all associated disburses" do
      @disburse = create :disburse, credit_agreement: @credit_agreement
      expect(@credit_agreement.balance_items).to include(@disburse)
    end

    it "does not contain disburses for other credit agreements" do
      @disburse = create :disburse
      expect(@credit_agreement.balance_items).not_to include(@disburse)
    end

    it "contain all associated balances" do
      @balance = create :balance, credit_agreement: @credit_agreement
      expect(@credit_agreement.balance_items).to include(@balance)
    end

    it "does not contain balances for other credit agreements" do
      @balance = create :balance
      expect(@credit_agreement.balance_items).not_to include(@balance)
    end

    it "creates missing balances" do
      @deposit = create :deposit, credit_agreement: @credit_agreement, date: Date.today - 1.year
      expect{
        @credit_agreement.balance_items
      }.to change(@credit_agreement.balances, :count).by(1)
    end

    it "contains a new balance for the current year" do
      @deposit = create :deposit, credit_agreement: @credit_agreement
      expect(@credit_agreement.balance_items.last).to be_a_new(Balance)
    end
  end

end
