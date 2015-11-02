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

  it "starts with a balance of 0" do
    pending 'implement balance'
    @credit_agreement = create :credit_agreement
    expect(@credit_agreement.balance(Date.today)).to eq(0)
  end

  it "a deposit is added to the credit_agreement" do
    pending 'implement balance'
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today
    expect(@credit_agreement.balance(Date.today)).to eq(1000)
  end

  #it "interest of deposits is taken into account", focus: true do
  #  @credit_agreement = create :credit_agreement, interest_rate: 2
  #  @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today - 30.days
  #  interest = (0.02 * 1000 * 30 / Date.today.end_of_year.yday).round(2)
  #  expect(@credit_agreement.balance).to eq(1000 + interest)
  #end

  #it "interest of deposits is taken into account - deposit from last year", focus: true do
  #  @credit_agreement = create :credit_agreement, interest_rate: 2
  #  @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today - 366.days
  #  this_years_interest = (@deposit.amount * 0.02 * (Date.today - Date.today.beginning_of_year) / Date.today.end_of_year.yday).round(2)
  #  last_years_interest = (@deposit.amount * 0.02 * (Date.today.beginning_of_year - @deposit.date) / (Date.today.beginning_of_year - 1.day).yday).round(2)
  #  expect(@credit_agreement.balance).to eq(1000 + last_years_interest + this_years_interest)
  #end
  #it "if received, balance equals amount", focus: true do
  #  @credit_agreement = create :credit_agreement, amount: 1000
  #  @credit_agreement.receive!
  #  expect(@credit_agreement.balance).to eq(1000)
  #end

  #it "can receive only a different amount", focus: true do
  #  @credit_agreement = create :credit_agreement, amount: 1000
  #  @credit_agreement.receive!(500)
  #  expect(@credit_agreement.balance).to eq(500)
  #end
end
