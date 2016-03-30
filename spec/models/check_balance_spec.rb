require 'rails_helper'

RSpec.describe CheckBalance do
  context "for a credit agreemtent with payments" do
    before(:each){
      @credit_agreement = create :credit_agreement, valid_from: Date.yesterday, amount: 10000
      create :deposit, date: Date.today, amount: 2000, credit_agreement: @credit_agreement
      @auto_balance = @credit_agreement.auto_balances.build(date: Date.today.end_of_year)
      @check_balance = CheckBalance.new(date: Date.today.end_of_year, credit_agreement: @credit_agreement)
    }

    it "breakpoints are the same as the ones of an auto balance" do
      expect(@check_balance.send(:breakpoints)).to eq(@auto_balance.send(:breakpoints))
    end

    it "sum_upto is the same as the one of an auto balance" do
      expect(@check_balance.send(:sum_upto, Date.today)).to eq(@auto_balance.send(:sum_upto, Date.today))
    end
  end

  context "for a credit agreemtent with old payments" do
    before(:each){
      @credit_agreement = create :credit_agreement, valid_from: Date.yesterday, amount: 10000
      create :deposit, date: Date.today.prev_year(2), amount: 2000, credit_agreement: @credit_agreement
      @auto_balance = @credit_agreement.auto_balances.build(date: Date.today.end_of_year)
      @check_balance = CheckBalance.new(date: Date.today.end_of_year, credit_agreement: @credit_agreement)
    }

    it "breakpoints are the same as the ones of an auto balance" do
      expect(@check_balance.send(:breakpoints)).to eq(@auto_balance.send(:breakpoints))
    end

    it "sum_upto is the same as the one of an auto balance" do
      expect(@check_balance.send(:sum_upto, Date.today)).to eq(@auto_balance.send(:sum_upto, Date.today))
    end
  end

  context "for a credit_agreement without payments" do
    before(:each){
      @credit_agreement = create :credit_agreement, valid_from: Date.yesterday, amount: 10000
      @check_balance = CheckBalance.new(credit_agreement: @credit_agreement)
    }

    it "breapoints are the valid_from date and the end of year" do
      expect(@check_balance.send(:breakpoints)).to eq( [@credit_agreement.valid_from, Date.today.end_of_year] )
    end

    it "breakpoints are the beginning and the end of the year, if valid from ist in last year" do
      @credit_agreement = create :credit_agreement, valid_from: Date.today.prev_year, amount: 10000
      @check_balance = CheckBalance.new(credit_agreement: @credit_agreement)
      expect(@check_balance.send(:breakpoints)).to eq( [Date.today.beginning_of_year, Date.today.end_of_year] )
    end

    it "sum_upto is the amount of the credit_agreement" do
      expect(@check_balance.send(:sum_upto, Date.today.end_of_year)).to eq @credit_agreement.amount
    end
  end

  it "has a default date of end of year" do
    expect(CheckBalance.new.date).to eq(Date.today.end_of_year)
  end

  it "cannot be saved" do
    balance = CheckBalance.new(credit_agreement: create(:credit_agreement))
    expect(balance).to be_valid
    expect{
      balance.save
    }.not_to change(Balance, :count)
  end
end
