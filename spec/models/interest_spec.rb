require 'rails_helper'

RSpec.describe Interest, type: :model do
  [:deposit, :disburse].each do |payment_type|
    describe "interest of #{payment_type}" do
      it "amount is calculated upto today by default for this years payments" do
        payment = create payment_type, date: Date.today - 1.day
        expect(payment.interest.interest_days).to eq(1)
      end

      it "amount is calculated upto end of payments year for las years payments" do
        payment = create payment_type, date: (Date.today - 1.year).end_of_year - 1.day
        expect(payment.interest.interest_days).to eq(1)
      end

      it "calculates the days in the payments year" do
        payment = create payment_type, date: '2015-10-1'
        expect(payment.interest.days_in_year).to eq(365)
      end

      it "calculates the days in the payments year for leap years" do
        payment = create payment_type, date: '2012-10-1'
        expect(payment.interest.days_in_year).to eq(366)
      end
    end
  end

  it "the interest of a deposit is calculated" do
    credit_agreement = create :credit_agreement, interest_rate: 2
    deposit = create :deposit, amount: 1000, date: '2015-10-1'
    expect(deposit.interest(Date.new(2015,10,31)).amount).to eq((1000 * 0.02 * 30 / 365).round(2))
  end

  it "the interest of a last_years deposit is calculated" do
    credit_agreement = create :credit_agreement, interest_rate: 2
    deposit = create :deposit, amount: 1000, date: '2014-11-30'
    expect(deposit.interest.amount).to eq((1000 * 0.02 * 31 / 365).round(2))
  end

  it "the interest of a disburse is calculated" do
    credit_agreement = create :credit_agreement, interest_rate: 2
    disburse = create :disburse, amount: 1000, date: '2015-10-1'
    expect(disburse.interest(Date.new(2015,10,31)).amount).to eq(-(1000 * 0.02 * 30 / 365).round(2))
  end

  describe "the interest of a balance" do
    it "calculates the interest days for this year" do
      balance = build :balance, date: Date.today
      expect(balance.interest_from_start_amount.interest_days).to eq(Date.today.yday)
    end

    it "calculates the interest days for last year" do
      balance = build :balance, date: (Date.today - 1.year).end_of_year
      expect(balance.interest_from_start_amount.interest_days).to eq(365)
    end

    it "calculates the interest amount for a whole year" do
      credit_agreement = create :credit_agreement, interest_rate: 5
      create :deposit, credit_agreement: credit_agreement, amount: 1000, date: (Date.today - 1.year).end_of_year
      old_balance = create :balance, credit_agreement: credit_agreement, date: (Date.today - 1.year).end_of_year, end_amount: 1000
      new_balance = build :balance, credit_agreement: credit_agreement, date: (Date.today.end_of_year)
      expect(new_balance.interest_from_start_amount.amount).to eq(50)
    end

    it "calculates the interest amount for a part of the year" do
      credit_agreement = create :credit_agreement, interest_rate: 5
      create :deposit, credit_agreement: credit_agreement, amount: 1000, date: '2014-12-31'
      old_balance = create :balance, credit_agreement: credit_agreement, date: '2014-12-31'
      new_balance = build :balance, credit_agreement: credit_agreement, date: '2015-01-31'
      expect(new_balance.interest_from_start_amount.amount).to eq((1000 * 0.05 * 31 / 365).round(2))
    end
    
  end
end

