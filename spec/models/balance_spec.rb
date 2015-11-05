require 'rails_helper'

RSpec.describe Balance, type: :model do
  before :each do
    @credit_agreement = create :credit_agreement, interest_rate: 2
  end

  it "has a default date of today" do
    expect(balance.date).to eq(Date.today)
  end

  it "date can be specified" do
    expect(balance('2013-12-02').date).to eq(Date.new(2013, 12, 02))
  end

  it "to interest" do
    @balance = balance
    expect(BalanceInterest).to receive(:new).with(@balance, @balance.date)
    @balance.to_interest
  end

  it "interest_from_start_amount" do
    create_deposit Date.today - 1.year, 1000
    @old_balance = balance (Date.today - 1.year).end_of_year
    @balance = balance
    expect(BalanceInterest).to receive(:new).with(@old_balance, @balance.date)
    @balance.interest_from_start_amount
  end

  describe 'last_years_balance' do
    it "is nil if no payments from previous years exist" do
      expect(balance.last_years_balance).to be_nil
    end

    it "is read from the database if it exists" do
      create_deposit Date.today - 1.year, 1000
      @old_balance = balance (Date.today - 1.year).end_of_year
      expect(balance.last_years_balance).to eq(@old_balance)
    end

    it "is created if a payment from last year exists, but no balance is saved" do
      create_deposit Date.today - 1.year, 1000
      expect(balance.last_years_balance).to be_persisted
    end
  end

  describe "start_amount" do
    it "is 0 if no payments from previous years exist" do
      create_deposit Date.today, 5000
      expect(balance.start_amount).to eq(0)
    end

    it "is the end amount of last year if payments from previous years exist" do
      create_deposit (Date.today - 1.year).end_of_year, 5000
      expect(balance.start_amount).to eq(5000.27)
    end
  end

  describe "end_amount" do
    it "is 0 for a new credit_agreement" do
      expect(balance.end_amount).to eq(0)
    end

    it "includes deposits on the credit_agreement" do
      create_deposit Date.today, 5000
      expect(balance.end_amount).to eq(5000)
    end

    it "does not includ deposits on other credit_agreements" do
      other_deposit = create :deposit, amount: 1111, date: Date.today
      expect(balance.end_amount).to eq(0)
    end

    it "includes disburses on the credit_agreement" do
      create_deposit Date.today, 5000
      create_disburse Date.today, 2000
      expect(balance.end_amount).to eq(3000)
    end

    it "does not include dispurses on other credit_agreements" do
      create_deposit Date.today, 5000
      create_disburse Date.today, 2000
      other_disburse = create :disburse, amount: 1111, date: Date.today
      expect(balance.end_amount).to eq(3000)
    end

    it "does not take future payments into account" do
      create_deposit '2015-10-10', 5000
      create_deposit Date.today, 5000
      create_disburse '2015-10-10', 2000
      create_disburse Date.today, 1000
      expect(balance('2015-10-10').end_amount).to eq(3000)
    end

    it "takes interest for a deposit into account" do
      create_deposit '2015-10-1', 5000
      expect(balance('2015-10-31').end_amount).to eq(5000 + (5000 * 0.02 * 30 / 365).round(2))
    end

    it "takes interest for a disburse into account" do
      create_deposit '2015-10-1', 5000
      create_disburse '2015-10-1', 2000
      expect(balance('2015-10-31').end_amount).to eq(3000 + (3000 * 0.02 * 30 / 365).round(2))
    end

    it "takes last years balance into account" do
      create_deposit '2014-10-1', 10000
      last_years_end_amount = 10000 + (10000 * 0.02 * 92 / 365).round(2)
      end_amount = last_years_end_amount + (last_years_end_amount * 0.02 * 30 / 365).round(2)
      expect(balance('2015-01-31').end_amount).to eq(end_amount)
    end

    it "calculates correctly since start of year" do
      create_deposit '2015-01-01', 10000
      expect(balance('2015-01-31').end_amount).to eq(10000 + (10000 * 0.02 * 30 / 365).round(2))
    end

    it "calculates correctly for the closing of year balance" do
      create_deposit '2014-12-1', 1000000
      expect(balance('2014-12-31').end_amount).to eq(1000000 + (1000000 * 0.02 * 31 / 365).round(2))
    end
  end

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def balance(date = Date.today)
    create :balance, credit_agreement: @credit_agreement, date: date
  end
end
