require 'rails_helper'

RSpec.describe Fund, type: :model do
  describe "validations" do
    it "is not valid without interest rate" do
      fund = build :fund, interest_rate: nil
      expect(fund).not_to be_valid
    end

    it "is not valid with a interest rate < 0" do
      fund = build :fund, interest_rate: -0.1
      expect(fund).not_to be_valid
    end

    it "is valid with a interest_rate = 0" do
      fund = build :fund, interest_rate: 0
      expect(fund).to be_valid
    end

    it "is not valid with a interest_rate >= 100" do
      fund = build :fund, interest_rate: 100
      expect(fund).not_to be_valid
    end

    it "is not valid without a date of issuing" do
      fund = build :fund, issued_at: nil
      expect(fund).not_to be_valid
    end

    it "the interest rate has to be uniq" do
      create :fund, interest_rate: 1
      fund = build :fund, interest_rate: 1
      expect(fund).not_to be_valid
    end

    Fund.valid_limits.each do |limit|
      it "is valid with a limit of '#{limit}'" do
        fund = build :fund, limit: limit
        expect(fund).to be_valid
      end
    end
    
    [nil, '', 1, 'nope'].each do |limit|
      it "is not valid with a limit of '#{limit}'" do
        fund = build :fund, limit: limit
        expect(fund).not_to be_valid
      end
    end
  end

  describe "limited_by_number_of_shares?" do
    it "is true if limit is set to number_of_shares" do
      fund = build :fund, limit: :number_of_shares
      expect(fund).to be_limited_by_number_of_shares
    end

    it "is false if limit is set to one_year_amount" do
      fund = build :fund, limit: 'one_year_amount'
      expect(fund).not_to be_limited_by_number_of_shares 
    end
  end

  describe "limited_by_one_year_amount" do
    it "is true if limit is set to one_year_amount" do
      fund = build :fund, limit: 'one_year_amount'
      expect(fund).to be_limited_by_one_year_amount
    end

    it "is false if limit is set to number_of_shares" do
      fund = build :fund, limit: :number_of_shares
      expect(fund).not_to be_limited_by_one_year_amount
    end
  end

  describe "still avalailable" do
    context "fund limited by number_of_shares" do
      before(:each){ @fund = create(:fund, limit: :number_of_shares) }

      it "is 20 shares if there is no share until now" do
        expect(@fund.still_available).to eq 20
      end

      [1, 3, 4].each do |number|
        it "is 19 shares if there allready is one" do
          create_list :credit_agreement, number, interest_rate: @fund.interest_rate
          expect(@fund.still_available).to eq 20 - number
        end
      end

      it "old credit agreemtents do not count to the limit" do
        @fund = create :fund, interest_rate: 2, issued_at: Date.today.beginning_of_year
        create :credit_agreement, interest_rate: @fund.interest_rate, valid_from: Date.today.prev_year
        expect(@fund.still_available).to eq 20
      end
    end

    context "fund limited by one_year_amount" do
      before(:each){ @fund = create(:fund, limit: 'one_year_amount', interest_rate: 1.3) }
      
      it "is 100.000 - interest that a credit would yield if there is no credit at all for this fund" do
        max = (100000 / (1 + (0.013 * (Date.today.end_of_year - Date.today) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
        expect(@fund.still_available).to eq max
      end

      it "takes allready received payments into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000
        deposit = create :deposit, credit_agreement: credit_agreement, amount: 10000, date: Date.today
        max = (100000 - deposit.amount * (1 + (0.013 * (Date.today.end_of_year - Date.today) / Date.today.end_of_year.yday) )).round(2)
        max = (max / (1 + (0.013 * (Date.today.end_of_year - Date.today) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
        expect(@fund.still_available).to eq max
      end

      it "takes an allready received payment and its interest of into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000
        deposit = create :deposit, credit_agreement: credit_agreement, amount: 10000, date: Date.today.prev_year.next_day
        interest = credit_agreement.auto_balances.last.interests_sum
        max = 100000 - deposit.amount - interest
        expect(@fund.still_available).to eq max
      end

      it "takes future payments into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000
        deposit = create :deposit, credit_agreement: credit_agreement, amount: 10000, date: Date.today
        interest = CheckBalance.new(credit_agreement: credit_agreement, date: Date.today.end_of_year).interests_sum
        max = 100000 - deposit.amount - interest
        max = (max / (1 + (0.013 * (Date.today.end_of_year - Date.today.prev_day) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
        expect(@fund.still_available(Date.today.prev_day)).to eq max
      end

      it "takes many allready received payments and their interest into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000
        deposit = create :deposit, credit_agreement: credit_agreement, amount: 10000, date: Date.today.prev_year.next_day
        credit_agreement2 = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 20000
        deposit2 = create :deposit, credit_agreement: credit_agreement2, amount: 20000, date: Date.today.prev_day(230)
        interest = credit_agreement.auto_balances.last.interests_sum
        interest2 = CheckBalance.new(credit_agreement: credit_agreement2, date: Date.today.prev_year.end_of_year).interests_sum
        max = 100000 - deposit.amount - interest - deposit2.amount - interest2
        expect(@fund.still_available).to eq max
      end

      it "takes interests from old credit_agreements into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000
        deposit = create :deposit, credit_agreement: credit_agreement, amount: 1, date: Date.today.prev_year.end_of_year
        interest = (1 * 0.013).round(2)
        max = ((100000 - interest) / (1 + (0.013 * (Date.today.end_of_year - Date.today) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
        expect(@fund.still_available).to eq max
      end

      it "takes new credit_agreements without payments into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000, valid_from: Date.yesterday
        interest = (10000 * (1 + (0.013 * (Date.today.end_of_year - Date.yesterday) / Date.today.end_of_year.yday) )).to_d.round(2)
        max = ((100000 - interest) / (1 + (0.013 * (Date.today.end_of_year - Date.today) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
        expect(@fund.still_available).to eq max
      end

      it "takes old credit_agreements without payments into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000, valid_from: Date.yesterday.prev_year(2)
        interest = (10000 * (1 + (0.013 * (Date.today.end_of_year.yday - 1)/Date.today.end_of_year.yday ))).to_d.round(2)
        max = ((100000 - interest) / (1 + (0.013 * (Date.today.end_of_year - Date.today) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
        expect(@fund.still_available).to eq max
      end
    end
  end
end
