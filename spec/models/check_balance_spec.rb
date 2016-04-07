require 'rails_helper'

RSpec.describe CheckBalance do
  context "for a credit agreemtent for which the whole amount was received" do
    before(:each){
      @credit_agreement = create :credit_agreement, valid_from: Date.yesterday, amount: 10000
      create :deposit, date: Date.today, amount: 10000, credit_agreement: @credit_agreement
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

  context "for a credit agreemtent for which the whole amount was received at least one year ago" do
    before(:each){
      @credit_agreement = create :credit_agreement, valid_from: Date.yesterday, amount: 10000
      create :deposit, date: Date.today.prev_year(2), amount: 10000, credit_agreement: @credit_agreement
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

  context "for a new credit_agreement where the amount is only partly received" do
    before(:each){
      @end_date = Date.today.end_of_year.prev_day(2)
      @credit_agreement = create :credit_agreement, valid_from: Date.today.beginning_of_year, amount: 10000
      @deposit = create :deposit, date: Date.today, amount: 2000, credit_agreement: @credit_agreement
      @check_balance = CheckBalance.new(date: @end_date, credit_agreement: @credit_agreement)
    }

    it "break_points are the valid_from date, the date of the payment and the end of the year" do
      expect(@check_balance.send(:breakpoints)).to eq( [@credit_agreement.valid_from, @deposit.date, @end_date] )
    end

    it "sum_upto is the open amount of the credit_agreement before the deposits date" do
      expect(@check_balance.send(:sum_upto, Date.yesterday)).to eq 8000
    end

    it "sum_upto is the whole amount of the credit_agreement after the deposits date" do
      expect(@check_balance.send(:sum_upto, Date.today)).to eq 10000
    end
  end

  context "for a old credit_agreement where the amount is only partly received" do
    before(:each){
      @credit_agreement = create :credit_agreement, valid_from: Date.today.prev_year(2), amount: 10000
      @deposit = create :deposit, date: Date.today.prev_year(1), amount: 2000, credit_agreement: @credit_agreement
    }
    let(:check_balance){ CheckBalance.new(date: @end_date, credit_agreement: @credit_agreement) } 

    context "first year - without payments" do
      before(:each){ @end_date = Date.today.prev_year(2).end_of_year }

      it "break_points are the valid_from date, an the balances date" do
        expect(check_balance.send(:breakpoints)).to eq( [@credit_agreement.valid_from, @end_date] )
      end

      it "sum_upto the end of year is the open amount" do
        expect(check_balance.send(:sum_upto, @end_date)).to eq 8000
      end

      #it "sum_upto is the whole amount of the credit_agreement after the deposits date" do
      #  expect(check_balance.send(:sum_upto, Date.today)).to eq 10000
      #end
    end

    context "second year - with a deposit" do
      before(:each){ @end_date = Date.today.prev_year(1).end_of_year }

      it "break_points are the beginning of the balances year, the deopsits date and the balances date" do
        expect(check_balance.send(:breakpoints)).to eq( [@end_date.beginning_of_year, @deposit.date,  @end_date] )
      end

      it "sum_upto the day before the deposits date is the open amount" do
        expect(check_balance.send(:sum_upto, @deposit.date.prev_day)).to eq 8000
      end

      it "sum_upto the deposits date is the whole amount" do
        expect(check_balance.send(:sum_upto, @deposit.date)).to eq 10000
      end

      it "sum_upto the deposits date is the whole amount" do
        expect(check_balance.send(:sum_upto, @end_date)).to eq 10000
      end
    end

    context "third year - without a deposit" do
      before(:each){ @end_date = Date.today.end_of_year }

      it "break_points are the beginning of the balances year  and the balances date" do
        expect(check_balance.send(:breakpoints)).to eq( [@end_date.beginning_of_year.prev_day, @end_date] )
      end

      it "sum_upto the first day of the year is the whole amount + real interest of last year" do
        expect(check_balance.send(:sum_upto, @end_date.beginning_of_year)).to eq @credit_agreement.balances.last.end_amount + 8000
      end

      it "sum_upto the last day of the year is the whole amount" do
        expect(check_balance.send(:sum_upto, @end_date)).to eq @credit_agreement.balances.last.end_amount + 8000
      end
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
