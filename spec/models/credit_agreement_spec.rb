require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe CreditAgreement, type: :model do
  before(:each){ allow_any_instance_of(Deposit).to receive(:not_before_credit_agreement_starts).and_return(true) }

  it "is only valid for project_accounts, not for a creditors account" do
    @account = create :person_account
    @credit_agreement = build :raw_credit_agreement, account: @account
    expect(@credit_agreement).not_to be_valid
  end

  it "is not valid without account" do
    @credit_agreement = build :raw_credit_agreement, account: nil
    expect(@credit_agreement).not_to be_valid
  end

  it "has a balance for today" do
    @credit_agreement = build :credit_agreement
    expect(@credit_agreement.todays_balance.date).to eq(Date.today)
    expect(@credit_agreement.todays_balance).to be_a(AutoBalance)
    expect(@credit_agreement.todays_balance).not_to be_persisted
  end

  it "total_interest is the interest amount upto today" do
    @credit_agreement = create :credit_agreement, amount: 50000, interest_rate: 2 
    create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today.prev_day(455)
    create :disburse, credit_agreement: @credit_agreement, amount: 9467, date: Date.today.prev_day(390)
    create :deposit, credit_agreement: @credit_agreement, amount: 1111, date: Date.today.prev_day(7)
    create :disburse, credit_agreement: @credit_agreement, amount: 555, date: Date.today.prev_day(2)
    @credit_agreement.reload
    expect(@credit_agreement.total_interest).to eq(
      (@credit_agreement.balances.to_a + [@credit_agreement.send(:todays_balance)]).sum(&:interests_sum)
    )
  end

  it "todays_total is the amount including interest upto today" do
    @credit_agreement = create :credit_agreement, amount: 50000, interest_rate: 2 
    create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today.prev_day(455)
    create :disburse, credit_agreement: @credit_agreement, amount: 9467, date: Date.today.prev_day(390)
    create :deposit, credit_agreement: @credit_agreement, amount: 1111, date: Date.today.prev_day(7)
    create :disburse, credit_agreement: @credit_agreement, amount: 555, date: Date.today.prev_day(2)
    @credit_agreement.reload
    expect(@credit_agreement.todays_total).to eq(
      @credit_agreement.auto_balances.build(date: Date.today).end_amount 
    )
  end

  it "its balances are sorted by date ascending" do
    @credit_agreement = create :credit_agreement
    create :balance, credit_agreement: @credit_agreement, date: Date.today
    create :balance, credit_agreement: @credit_agreement, date: Date.today - 2.years
    create :balance, credit_agreement: @credit_agreement, date: Date.today - 1.years
    expected_order = [Date.today - 2.years, Date.today - 1.years, Date.today]
    expect(@credit_agreement.balances.pluck(:date)).to eq(expected_order)
  end

  it "is not active if it has no payments" do
    @credit_agreement = create :credit_agreement
    expect(@credit_agreement).not_to be_active
  end

  it "is active if it has payments" do
    @credit_agreement = create :credit_agreement
    create :deposit, credit_agreement: @credit_agreement
    expect(@credit_agreement.reload).to be_active
  end
  
  it "is not active if it is terminated" do
    @credit_agreement = create :credit_agreement
    create :deposit, credit_agreement: @credit_agreement
    allow(@credit_agreement).to receive(:terminated?).and_return(true)
    expect(@credit_agreement.reload).not_to be_active
  end

  it "termination date is empty by default" do
    @credit_agreement = create :credit_agreement
    expect(@credit_agreement.terminated_at).to be_nil
  end

  it "is not terminated if termination date is not set" do
    @credit_agreement = build :credit_agreement
    expect(@credit_agreement).not_to be_terminated
  end

  it "is terminated if termination date is set" do
    @credit_agreement = build :credit_agreement, terminated_at: Date.today
    expect(@credit_agreement).to be_terminated
  end

  it "on being terminated, it calls its Terminator" do
    @credit_agreement = create :credit_agreement
    allow_any_instance_of(CreditAgreementTerminator).to receive(:terminate).and_return(true)
    expect(CreditAgreementTerminator).to receive(:new).with(@credit_agreement).and_call_original
    expect_any_instance_of(CreditAgreementTerminator).to receive(:terminate).with(no_args)
    @credit_agreement.update(terminated_at: Date.today)
  end

  it "does not call the terminator upon an update, if it is allready terminated" do
    @credit_agreement = create :credit_agreement
    create :deposit, credit_agreement: @credit_agreement
    @credit_agreement.update_column(:terminated_at, Date.today)
    expect(CreditAgreementTerminator).not_to receive(:new)
    @credit_agreement.reload.save
  end

  describe 'its number' do
    it "may be left blank" do
      @credit_agreement = build :credit_agreement, number: nil
      expect(@credit_agreement).to be_valid
    end

    it "is set automatically" do
      @credit_agreement = create :credit_agreement, number: nil
      expect(@credit_agreement.number).to eq("#{@credit_agreement.account_id}0001")
    end

    it "has to be uniq" do
      @credit_agreement = create :credit_agreement, number: 21
      @credit_agreement2 = build :credit_agreement, number: 21
      expect(@credit_agreement2).not_to be_valid
    end

    it "is autoincremented" do
      @credit_agreement = create :credit_agreement, number: 'AB0001'
      @credit_agreement2 = create :credit_agreement, account: @credit_agreement.account, number: nil
      expect(@credit_agreement2.number).to eq('AB0002')
    end
  end

  describe "year_terminated?" do
    it "is false if no balance_pdf exists" do
      @credit_agreement = create :credit_agreement
      expect(@credit_agreement.year_terminated?(2014)).to be_falsy
    end

    it "is true if a balance_pdf for that or a later year exists" do
      allow_any_instance_of(BalanceLetter).to receive(:to_pdf).and_return(:true)
      @credit_agreement = create :credit_agreement
      @letter = create :balance_letter, year: 2014
      create :pdf, letter: @letter, creditor: @credit_agreement.creditor
      expect(@credit_agreement.year_terminated?(2013)).to be_truthy
      expect(@credit_agreement.year_terminated?(2014)).to be_truthy
      expect(@credit_agreement.year_terminated?(2015)).to be_falsy
    end
  end

  context "whith a termination date" do
    before :each do
      @credit_agreement = create :credit_agreement, amount: 50000, interest_rate: 2 
      create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today.prev_year
      create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today
      @credit_agreement.reload
    end

    it "before any of its payments is invalid" do
      @credit_agreement.terminated_at = Date.yesterday
      expect(@credit_agreement).not_to be_valid
    end

    it "that is equal to the date of its last payment is valid" do
      @credit_agreement.terminated_at = Date.today
      expect(@credit_agreement).to be_valid
    end

    it "after the date of its last payment is valid" do
      @credit_agreement.terminated_at = Date.tomorrow
      expect(@credit_agreement).to be_valid
    end
  end

  describe "issued_at" do
    it "is the valid_from date if there is no payment yet" do
      credit_agreement = create :credit_agreement, valid_from: Date.today.beginning_of_year
      expect(credit_agreement.issued_at).to eq Date.today.beginning_of_year
    end

    it "is the date of the first payment" do
      credit_agreement = create :credit_agreement, valid_from: Date.today.prev_year.beginning_of_year
      create :deposit, credit_agreement: credit_agreement, date: Date.today
      create :deposit, credit_agreement: credit_agreement, date: Date.yesterday
      expect(credit_agreement.issued_at).to eq Date.yesterday
    end
  end

  describe "check balance" do
    it "is the hypothetical balance (for validations) at the end of this year by default" do
      credit_agreement = create :credit_agreement
      expect(CheckBalance).to receive(:new).with(credit_agreement: credit_agreement, date: Date.today.end_of_year)
      credit_agreement.check_balance
    end

    it "is the hypothetical balance (for validations) at a given date" do
      credit_agreement = create :credit_agreement
      date = Date.today
      expect(CheckBalance).to receive(:new).with(credit_agreement: credit_agreement, date: date)
      credit_agreement.check_balance(date)
    end
  end

  describe "versioning" do
    before(:each){ 
      @credit = create :credit_agreement, interest_rate: 1, valid_from: Date.new(2016,1,1)
    }

    it "is vesioned" do
      expect(@credit).to be_versioned 
    end

    with_versioning do
      it "has a version for create" do
        expect(@credit.versions.count).to eq(1)
      end

      it "is versioned on update" do
        expect{
          @credit.update_attributes!(amount: 1999)
        }.to change(@credit.versions, :count).by(1)
      end

      it "is versioned on destroy" do
        expect{
          @credit.destroy!
        }.to change(@credit.versions, :count).by(1)
      end

      describe "change of valid_from" do
        it "valid_from may not be changed to a year, which is allready terminated" do
          @credit_agreement = create :credit_agreement, valid_from: Date.today
          allow_any_instance_of(Creditor).to receive(:year_terminated?).and_return(true)
          expect(@credit_agreement.update_attributes(valid_from: Date.yesterday)).to be_falsy
          expect(@credit_agreement.errors[:valid_from]).not_to be_empty
        end
      end
    end
  end

  describe "# When to check if a fund exists for the credit agreements interest rate" do
    def build_fund_and_credit(fund_issued_at:, credit_agreement_issued_at:)
      @project = create :project_address, :with_default_account
      @fund = create :fund, project_address: @project, issued_at: Date.new(*fund_issued_at)
      @credit_agreement = build :raw_credit_agreement, 
        interest_rate: @fund.interest_rate, 
        account: @project.accounts.first,
        valid_from: Date.new(*credit_agreement_issued_at)
    end

    context "if the project does not use the transitional regulation (KaSchG takes effect on 10.7.2015)" do
      before(:each){ 
        create :boolean_setting, category: 'legal_regulation', name: 'utilize_transitional_regulation', value: false
      }

      context "and the credit agreement starts before the 10.7.2015" do
        it "the credit agreement is valid if no fund exists" do
          expect(Fund.utilize_transitional_regulation).to be_falsy
          @credit_agreement = build :raw_credit_agreement, valid_from: Date.new(2015, 7, 9)
          expect(@credit_agreement).to be_valid
        end

        it "the credit agreement is valid if a fund exists - even if the fund is issued after the credit agreement" do
          build_fund_and_credit(fund_issued_at: [2015, 7, 10], credit_agreement_issued_at: [2015, 1, 1])
          expect(Fund.utilize_transitional_regulation).to be_falsy
          expect(@credit_agreement).to be_valid
        end
      end

      context "and the credit agreement starts after or at the 10.7.2015" do
        it "the credit_agreement is valid if a fund exists" do
          build_fund_and_credit(fund_issued_at: [2015, 7, 10], credit_agreement_issued_at: [2015, 7, 10])
          expect(@credit_agreement).to be_valid
        end

        it "the credit agreement is invalid if the fund does not exist" do
          @credit_agreement = build :raw_credit_agreement, valid_from: Date.new(2015, 7, 10)
          expect(@credit_agreement).not_to be_valid
        end

        it "the credit agreement is invalid if it is issued after or on the 10.7.2015 but before the issuing of the fund" do
          build_fund_and_credit(fund_issued_at: [2015, 7, 11], credit_agreement_issued_at: [2015, 7, 10])
          expect(@credit_agreement).not_to be_valid
        end
      end
    end

    context "if the project uses the transitional regulation (KaSchG takes effect on 1.1.2016)" do
      before(:each){ 
        create :boolean_setting, category: 'legal_regulation', name: 'utilize_transitional_regulation', value: true
      }
      context "and the credit agreement starts before the 1.1.2016" do
        it "the credit agreement is valid if no fund exists" do
          expect(Fund.utilize_transitional_regulation).to be_truthy
          @credit_agreement = build :raw_credit_agreement, valid_from: Date.new(2015, 12, 31)
          expect(@credit_agreement).to be_valid
        end

        it "the credit agreement is valid if a fund exists - even if the fund is issued after the credit agreement" do
          build_fund_and_credit(fund_issued_at: [2016, 1, 1], credit_agreement_issued_at: [2015, 12, 31])
          expect(@credit_agreement).to be_valid
        end
      end

      context "and the credit agreement starts after or at the 1.1.2016" do
        it "the credit_agreement is valid if a fund exists" do
          build_fund_and_credit(fund_issued_at: [2016, 1, 1], credit_agreement_issued_at: [2016, 1, 1])
          expect(@credit_agreement).to be_valid
        end

        it "the credit agreement is invalid if the fund does not exist" do
          @credit_agreement = build :raw_credit_agreement, valid_from: Date.new(2016, 1, 1)
          expect(@credit_agreement).not_to be_valid
        end

        it "the credit agreement is invalid if it is issued after or on the 1.1.2016 but before the issuing of the fund" do
          build_fund_and_credit(fund_issued_at: [2016, 1, 2], credit_agreement_issued_at: [2016, 1, 1])
          expect(@credit_agreement).not_to be_valid
        end
      end
    end
  end

  describe "respects the funds limit" do
    before(:each){ @project = create :project_address, :with_default_account }

    context "of 100000 per year" do
      context "if the credit agreement is issued before the KaSchG takes effect" do
        before(:each){ 
          @fund = create :fund, limit: 'one_year_amount', project_address: @project, issued_at: Date.today.beginning_of_year 
        }

        it "it is valid with any amount" do
          expect(credit_agreement(200000, date: Date.new(2015, 1, 1))).to be_valid
        end

        context "changing its" do
          before(:each){
            @credit_agreement = credit_agreement(200000, date: Date.new(2015,1,1))
            @credit_agreement.save
          }

          it "amount is possible" do
            @credit_agreement.amount += 100000
            expect(@credit_agreement).to be_valid
          end

          it "interest rate is possible" do
            @credit_agreement.interest_rate += 1
            expect(@credit_agreement).to be_valid
          end

          it "issuing date (valid_from) is possible" do
            @credit_agreement.valid_from = Date.new(2015, 3, 3)
            expect(@credit_agreement).to be_valid
          end

          it "issuing date (valid_from) to a date after KaSchG takes effect is impossible" do
            @credit_agreement.valid_from = Date.new(2016, 1, 1)
            expect(@credit_agreement).not_to be_valid
            expect(@credit_agreement.errors[:amount]).to include 'zu hoch - max 90.939,92 € möglich'
          end
        end
      end

      context "if the credit agreement is issued after KaSchG takes effect" do
        before(:each){ 
          @fund = create :fund, limit: 'one_year_amount', project_address: @project, issued_at: Date.today.beginning_of_year 
        }

        {
          'at the first day of year' => [2017, 1, 1, 10],
          'somwhere in the middle of the year' => [2017, 5, 17, 10],
          'at the last day of year' => [2017, 12, 31, 10]
        }.each do |on_date, date_today|
          context "#{on_date}" do
            before(:all){ Timecop.freeze(Time.local(*date_today)) }
            after(:all){ Timecop.return }

            context "a new credit agreement" do
              before(:each){
                end_date = on_date == 'at the last day of year' ? Date.today.next_year : Date.today.end_of_year
                @limit = ReverseInterestCalculator.new(
                  base_amount: 100000, fund: @fund, start_date: Date.today, end_date: end_date
                ).maximum_credit
              }

              it "is valid if its amount is less then or eq to the amount still available for that fund" do
                expect(credit_agreement(@limit)).to be_valid
              end

              it "is invalid if its amount is bigger than the amount still available for that fund" do
                @credit_agreement = credit_agreement(@limit + 0.01)
                expect(@credit_agreement).not_to be_valid
                expect(@credit_agreement.errors[:amount]).to include "zu hoch - max #{number_to_currency(@limit)} möglich"
              end
            end

            context "when changing" do
              before(:each){ 
                @fund = create :fund, limit: 'one_year_amount', project_address: @project, issued_at: Date.today.beginning_of_year, interest_rate: 1 }

              context "the amount" do
                before(:each){
                  credit_agreement(1000, date: Date.today.beginning_of_year).save
                  @credit_agreement = CreditAgreement.last
                }

                context "for a credit agreement without payments" do
                  it "the credit agreement is valid if i do not reach the limit" do
                    @credit_agreement.amount = 99012
                    expect(@credit_agreement).to be_valid
                  end

                  it "the credit agreement is invalid if i change amount to something bigger than the limit" do
                    @credit_agreement.amount = 99013
                    expect(@credit_agreement).not_to be_valid
                  end
                end

                context "for a credit agreement with payments" do
                  before(:each){ create(:deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.beginning_of_year) }

                  it "is valid" do
                    expect(@credit_agreement).to be_valid
                  end

                  it "is valid if the amount change is smaller than the available amount" do
                    limit = @fund.still_available(Date.today.beginning_of_year)
                    @credit_agreement.amount += limit
                    expect(@credit_agreement).to be_valid
                  end

                  it "is not valid if the amount change is bigger than the available amount" do
                    limit = @fund.still_available(Date.today.beginning_of_year)
                    @credit_agreement.amount += (limit + 0.01)
                    expect(@credit_agreement).not_to be_valid
                    expect(@credit_agreement.errors[:amount]).to include "zu hoch - max 99.012,58 € möglich"
                  end
                end

                context "for a old credit agreement (issued before KaSchG) with payments" do
                  before(:each){
                    @credit_agreement = credit_agreement(1000, date: Date.new(2015,1,1))
                    @credit_agreement.save
                    @credit_agreement.reload
                    create(:deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.beginning_of_year) 
                  }

                  it "by 0 is valid" do
                    expect(@credit_agreement).to be_valid
                  end

                  it "is valid if the amount change is smaller than the available amount" do
                    limit = @fund.still_available(Date.today.beginning_of_year)
                    @credit_agreement.amount += limit
                    expect(@credit_agreement).to be_valid
                  end

                  it "is  valid even if the amount change is bigger than the available amount" do
                    limit = @fund.still_available(Date.today.beginning_of_year)
                    @credit_agreement.amount = 2 * limit
                    expect(@credit_agreement).to be_valid
                  end
                end
              end
            end
          end
        end
      end

      context "these validations do not raise an error if" do
        before(:each){ 
          @fund = create :fund, limit: 'one_year_amount', project_address: @project
        }

        it "valid_from is missing" do
          expect{credit_agreement(1000, date: nil).valid?}.not_to raise_error
        end

        it " account is missing" do
          expect{credit_agreement(1000, account: nil).valid?}.not_to raise_error
        end

        it "interest_rate is missing" do
          expect{credit_agreement(1000, interest_rate: nil).valid?}.not_to raise_error
        end

        it "amount is missing" do
          expect{credit_agreement(nil).valid?}.not_to raise_error
        end
        
        it "everything is missing" do
          expect{credit_agreement(nil, interest_rate: nil, account: nil, date: nil).valid?}.not_to raise_error
        end
      end
    end

    context "of 20 shares in total" do
      before(:each){
        @fund = create :fund, limit: 'number_of_shares', project_address: @project, issued_at: Date.today.beginning_of_year
      }

      context "a new credit agreement" do
        it "is valid if ther are less than 20 credit_agreements for that fund" do
          19.times{ credit_agreement(1000, date: Date.today.beginning_of_year).save }
          expect(credit_agreement(20000)).to be_valid
        end

        it "is invalid if there allready are 20 credit_agreements for that fund" do
          20.times{ credit_agreement(1000, date: Date.today.beginning_of_year).save }
          expect(credit_agreement(20000)).not_to be_valid
        end

        it "is valid independetly of the number of shares, if it was issued before the KaSchG takes effect" do
          20.times{ credit_agreement(1000, date: Date.today.beginning_of_year).save }
          expect(credit_agreement(20000.01, date: Date.new(2015, 7, 9))).to be_valid
        end
      end

      context "when changing a credit_agreement" do
        it "is valid if there are 19" do
          19.times{ credit_agreement(1000, date: Date.today.beginning_of_year).save }
          @credit_agreement = CreditAgreement.last
          @credit_agreement.amount = 99012
          expect(@credit_agreement).to be_valid
        end

        it "is valid even if there allready are 20" do
          20.times{ credit_agreement(1000, date: Date.today.beginning_of_year).save }
          @credit_agreement = CreditAgreement.last
          @credit_agreement.amount = 99013
          expect(@credit_agreement).to be_valid
        end
      end
    end

    def credit_agreement(amount, date: Date.today, interest_rate: @fund.interest_rate, account: @project.accounts.first)
       build :raw_credit_agreement, interest_rate: interest_rate, account: account, amount: amount, valid_from: date
    end
  end

  describe "- the class - can calculate" do
    before :each do
      @account_1 = create :project_account
      @account_2 = create :project_account
      @credit_1 = create :credit_agreement, account: @account_1, amount: 1000, interest_rate: '1'
      @credit_2 = create :credit_agreement, account: @account_1, amount: 2000, interest_rate: '2'
      @credit_3 = create :credit_agreement, account: @account_2, amount: 4000, interest_rate: '3'
    end

    it "the average the rate of interest over all project accounts" do
      expect(CreditAgreement.average_rate_of_interest).to be_within(0.001).of(2.428)
    end

    it "the sum of credits over all project agreements" do
      expect(CreditAgreement.funded_credits_sum).to eq(7000)
    end
  end
end
  
