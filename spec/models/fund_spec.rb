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

    it "is not valid without an associated project address" do
      fund = build :fund, project_address: nil
      expect(fund).not_to be_valid
    end

    describe "the interest_rate has to be uniq for one project address" do
      it "- two fund with the same rat for the same project are invalid" do
        fund = create :fund, interest_rate: 1
        other_fund = build :fund, interest_rate: 1, project_address: fund.project_address
        expect(other_fund).not_to be_valid
      end

      it "- two fund with the same rate for different project addresses are valid" do
        fund = create :fund, interest_rate: 1
        other_fund = build :fund, interest_rate: 1
        expect(other_fund).to be_valid
      end

      it "- thow funds with different rates for the same project address are valid" do
        fund = create :fund, interest_rate: 1
        other_fund = build :fund, interest_rate: 2, project_address: fund.project_address
        expect(other_fund).to be_valid
      end
    end

    describe "limits" do
      context "bagatelle_limits are not enforced" do
        before(:each){
          create :boolean_setting, category: 'legal_regulation', name: 'enforce_bagatelle_limits', value: false
          Setting.update_config
        }

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

      context "bagatelle_limits are enforced" do
        before(:each){
          create :boolean_setting, category: 'legal_regulation', name: 'enforce_bagatelle_limits', value: true
          Setting.update_config
        }

        (Fund.valid_limits - [:none]).each do |limit|
          it "is valid with a limit of '#{limit}'" do
            fund = build :fund, limit: limit
            expect(fund).to be_valid
          end
        end
        
        [nil, '', 1, 'nope', 'none'].each do |limit|
          it "is not valid with a limit of '#{limit}'" do
            fund = build :fund, limit: limit
            expect(fund).not_to be_valid
          end
        end
      end
    end
  end
  
  describe "regulated_from" do
    it "is 2015-07-10 without transitional regulation" do
      create :boolean_setting, category: 'legal_regulation', name: 'utilize_transitional_regulation', value: false
      Setting.update_config

      expect(Fund.regulated_from).to eq Date.new(2015, 7, 10)
    end

    it "is 2016-01-01 with transitional regulation" do
      create :boolean_setting, category: 'legal_regulation', name: 'utilize_transitional_regulation', value: true 
      Setting.update_config
      expect(Fund.regulated_from).to eq Date.new(2016, 1, 1)
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

  describe "credit_agreements" do
    before(:each){ 
      @project_address = create :project_address, :with_default_account
      @account = @project_address.accounts.first
      @fund = create :fund, interest_rate: 2, project_address: @project_address 
    }

    it "a credit_agreement with the same interest rate for the same project_address_id counts" do
      credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, account: @account
      expect(@fund.credit_agreements).to eq([credit_agreement])
    end

    it "a credit_agreement with the same interest rate for the same project_address counts, even on a different account" do
      credit_agreement_1 = create :credit_agreement, interest_rate: @fund.interest_rate, account: @account
      account_2 = create :account, address: @project_address
      credit_agreement_2 = create :credit_agreement, interest_rate: @fund.interest_rate, account: account_2
      expect(@fund.credit_agreements).to eq([credit_agreement_1, credit_agreement_2])
    end

    it "a credit_agreement with the same interest_rate an other project_address does not count" do
      credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, account: @account
      create :credit_agreement, interest_rate: @fund.interest_rate
      expect(@fund.credit_agreements).to eq([credit_agreement])
    end

    it "a credit_agreement with a different interest_rate and thje same project_address does not count" do
      credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, account: @account
      create :credit_agreement, interest_rate: 3.33, account: @account 
      expect(@fund.credit_agreements).to eq([credit_agreement])
    end
  end

  describe "still avalailable" do
    context "fund limited by number_of_shares" do
      before(:each){ @fund = create(:fund, limit: :number_of_shares) }

      it "is 20 shares if there is no share until now" do
        expect(@fund.still_available).to eq 20
      end

      [1, 3, 4].each do |number|
        it "is #{20-number} shares if there allready is #{number}" do
          account = @fund.project_address.accounts.first
          create_list :credit_agreement, number, interest_rate: @fund.interest_rate, account: account
          expect(@fund.still_available).to eq 20 - number
        end
      end

      it "is 20 shares if there is a credit_agreement with the same interest_amount, but for a different emittent" do
        create :credit_agreement, interest_rate: @fund.interest_rate
        expect(@fund.still_available).to eq 20
      end

     # it "old credit agreemtents do not count to the limit" do
     #   #TODO: Altfallregelung
     #   @fund = create :fund, interest_rate: 2, issued_at: Date.today.beginning_of_year
     #   create :credit_agreement, interest_rate: @fund.interest_rate, valid_from: Date.today.prev_year
     #   expect(@fund.still_available).to eq 20
     # end
    end

    context "fund limited by one_year_amount" do
      before(:each){ 
        @fund = create(:fund, limit: 'one_year_amount', interest_rate: 1.3) 
        @account = @fund.project_address.accounts.first
        @same_project_account = create :account, address: @fund.project_address
        dont_validate_fund_for CreditAgreement
      }
      
      it "is 100.000 - interest that a credit would yield if there is no credit at all for this fund" do
        max = without_coming_interests(100000, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "takes allready received payments into account" do
        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement)
        max = 100000 - deposit.amount - credit_agreement.check_balance.interests_sum
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "takes allready received payments into account, even on a different account of the same project address" do
        credit_agreement = credit_for_fund(@fund, 10000, account: @same_project_account)
        deposit = deposit_for_credit(credit_agreement)
        max = 100000 - deposit.amount - credit_agreement.check_balance.interests_sum
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "dos not take payments for an other project address into account" do
        credit_agreement = create :credit_agreement, interest_rate: @fund.interest_rate, amount: 10000
        deposit = deposit_for_credit(credit_agreement)
        max = without_coming_interests(100000, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "takes an allready received payment and its interest of into account" do
        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement, date: Date.tomorrow.prev_year)
        interest = credit_agreement.auto_balances.last.interests_sum
        max = 100000 - deposit.amount - interest
        expect(@fund.still_available).to eq max
      end

      it "takes future payments into account" do
        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement)
        interest = credit_agreement.check_balance.interests_sum
        max = 100000 - deposit.amount - interest
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.yesterday)
        expect(@fund.still_available(Date.today.prev_day)).to eq max
      end

      it "takes many allready received payments and their interest into account" do
        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement, date: Date.tomorrow.prev_year)
        credit_agreement2 = credit_for_fund(@fund, 20000)
        deposit2 = deposit_for_credit(credit_agreement2, date: Date.today.prev_day(230))
        interest = credit_agreement.auto_balances.last.interests_sum
        interest2 = credit_agreement2.check_balance(Date.today.prev_year.end_of_year).interests_sum
        max = 100000 - deposit.amount - interest - deposit2.amount - interest2
        expect(@fund.still_available).to eq max
      end

      it "takes interests from old credit_agreements into account" do
        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement, amount: 1, date: Date.today.prev_year.end_of_year)
        max = 100000 - credit_agreement.check_balance.interests_sum
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "takes new credit_agreements without payments into account" do
        credit_agreement = credit_for_fund(@fund, 10000, valid_from: Date.yesterday)
        max = 100000 - credit_agreement.check_balance.end_amount
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "takes old credit_agreements without payments into account" do
        credit_agreement = credit_for_fund(@fund, 10000, valid_from: Date.yesterday.prev_year(2))
        max = 100000 - credit_agreement.check_balance.end_amount
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "combines the different calculations 1" do
        credit_agreement1 = credit_for_fund(@fund, 10000, valid_from: Date.yesterday.prev_year(2))
        credit_agreement2 = credit_for_fund(@fund, 10000, valid_from: Date.yesterday)
        max = 100000 - credit_agreement1.check_balance.end_amount - credit_agreement2.check_balance.end_amount
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.today)
        expect(@fund.still_available).to eq max
      end

      it "combines the different calculations 2" do
        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement, date: Date.today.prev_year)
        interest = credit_agreement.auto_balances.last.interests_sum
        max = 100000 - deposit.amount - interest

        credit_agreement = credit_for_fund(@fund, 1000)
        deposit = deposit_for_credit(credit_agreement)
        
        expect(@fund.still_available(Date.yesterday)).to eq max
      end

      it "combines the different calculations 3" do
        credit_agreement = credit_for_fund(@fund, 1000)
        deposit = deposit_for_credit(credit_agreement, date: Date.today.prev_year)
        interest1 = credit_agreement.check_balance.interests_sum

        credit_agreement = credit_for_fund(@fund, 10000)
        deposit = deposit_for_credit(credit_agreement)
        interest2 = credit_agreement.check_balance.interests_sum

        max = 100000 - deposit.amount - interest1 - interest2
        max = without_coming_interests(max, interest_rate: @fund.interest_rate, date: Date.yesterday)
        expect(@fund.still_available(Date.yesterday)).to eq max
      end
    end
  end

  def without_coming_interests(amount, interest_rate:, date:)
    (amount / (1 + (interest_rate / 100 * (Date.today.end_of_year - date) / Date.today.end_of_year.yday) )).to_d.floor_to(0.01)
  end

  def credit_for_fund(fund, amount, account: nil, valid_from: nil)
    account ||= fund.project_address.accounts.first
    valid_from ||= Date.today
    create :credit_agreement, interest_rate: fund.interest_rate, amount: amount, account: account, valid_from: valid_from
  end

  def deposit_for_credit(credit_agreement, amount: credit_agreement.amount, date: Date.today)
    create :deposit, credit_agreement: credit_agreement, amount: amount, date: date 
  end
end
