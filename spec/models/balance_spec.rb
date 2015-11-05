require 'rails_helper'

RSpec.describe Balance, type: :model do
  it "has a default date of today" do
    @balance = Balance.new
    expect(@balance.date).to eq(Date.today)
  end

  it "has an amount of 0 for a new credit_agreement" do
    @balance = create :balance
    expect(@balance.amount).to eq(0)
  end

  it "includes deposits on the credit_agreement" do
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, date: Date.today, amount: 5000
    @balance = create :balance, credit_agreement: @credit_agreement, date: Date.today
    expect(@balance.amount).to eq(5000)
  end

  it "includes disburses on the credit_agreement" do
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, date: Date.today, amount: 5000
    @disburse = create :disburse, credit_agreement: @credit_agreement, date: Date.today, amount: 2000
    @balance = create :balance, credit_agreement: @credit_agreement, date: Date.today
    expect(@balance.amount).to eq(3000)
  end

  it "does not take future payments into account" do
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, date: '2015-10-10', amount: 5000
    new_deposit = create :deposit, credit_agreement: @credit_agreement, date: Date.today, amount: 5000
    @disburse = create :disburse, credit_agreement: @credit_agreement, date: '2015-10-10', amount: 2000
    new_disburse = create :disburse, credit_agreement: @credit_agreement, date: Date.today, amount: 1000
    @balance = create :balance, credit_agreement: @credit_agreement, date: '2015-10-10'
    expect(@balance.amount).to eq(3000)
  end

  it "takes interest for a deposit into account" do
    @credit_agreement = create :credit_agreement, interest_rate: 2
    @deposit = create :deposit, credit_agreement: @credit_agreement, date: '2015-10-1', amount: 5000
    @balance = create :balance, credit_agreement: @credit_agreement, date: '2015-10-31'
    expect(@balance.amount).to eq(5000 + (5000 * 0.02 * 30 / 365).round(2))
  end

  it "takes interest for a disburse into account" do
    @credit_agreement = create :credit_agreement, interest_rate: 2
    @deposit = create :deposit, credit_agreement: @credit_agreement, date: '2015-10-1', amount: 5000
    @disburse = create :disburse, credit_agreement: @credit_agreement, date: '2015-10-1', amount: 2000
    @balance = create :balance, credit_agreement: @credit_agreement, date: '2015-10-31'
    expect(@balance.amount).to eq(3000 + (3000 * 0.02 * 30 / 365).round(2))
  end

  it "taks last years balance into account" do
    @credit_agreement = create :credit_agreement, interest_rate: 2
    @last_years_deposit = create :deposit, credit_agreement: @credit_agreement, date: '2014-10-1', amount: 10000
    @balance = create :balance, credit_agreement: @credit_agreement, date: '2015-01-31'
    last_years_end_amount = 10000 + (10000 * 0.02 * 92 / 365).round(2)
    expect(@balance.amount).to eq(last_years_end_amount + (last_years_end_amount * 0.02 * 30 / 365).round(2))
  end

  it "calculates correctly since start of year" do
    @credit_agreement = create :credit_agreement, interest_rate: 2
    @last_years_deposit = create :deposit, credit_agreement: @credit_agreement, date: '2015-01-01', amount: 10000
    @balance = create :balance, credit_agreement: @credit_agreement, date: '2015-01-31'
    expect(@balance.amount).to eq(10000 + (10000 * 0.02 * 30 / 365).round(2))
  end

  it "calculates correctly for the closing of year balance" do
    @credit_agreement = create :credit_agreement, interest_rate: 2
    deposit = create :deposit, credit_agreement: @credit_agreement, date: '2014-12-1', amount: 1000000
    @balance = create :balance, credit_agreement: @credit_agreement, date: '2014-12-31'
    expect(@balance.amount).to eq(deposit.amount + (deposit.amount * 0.02 * 31 / 365).round(2))
  end
end
