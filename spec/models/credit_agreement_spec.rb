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

  it "is not valid without account" do
    @credit_agreement = build :credit_agreement, account: nil
    expect(@credit_agreement).not_to be_valid
  end

  describe 'number' do
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

    it "will be autoincremented" do
      @credit_agreement = create :credit_agreement, number: 'AB0001'
      @credit_agreement2 = create :credit_agreement, account: @credit_agreement.account, number: nil
      expect(@credit_agreement2.number).to eq('AB0002')
    end
  end

  it "has a todays balance" do
    @credit_agreement = build :credit_agreement
    expect(@credit_agreement.todays_balance.date).to eq(Date.today)
    expect(@credit_agreement.todays_balance).to be_a(AutoBalance)
    expect(@credit_agreement.todays_balance).not_to be_persisted
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

  context "termination_date" do
    before :each do
      @credit_agreement = create :credit_agreement, amount: 2000, interest_rate: 2 
      create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today.prev_year
      create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today
      @credit_agreement.reload
    end

    it "is not valid if it has payments after termination date" do
      @credit_agreement.terminated_at = Date.yesterday
      expect(@credit_agreement).not_to be_valid
    end

    it "is valid if the last payment is on the same date" do
      @credit_agreement.terminated_at = Date.today
      expect(@credit_agreement).to be_valid
    end

    it "is valid if termination date is after the last payment" do
      @credit_agreement.terminated_at = Date.tomorrow
      expect(@credit_agreement).to be_valid
    end
  end

  it "todays_total" do
    @credit_agreement = create :credit_agreement, amount: 2000, interest_rate: 2 
    create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today.prev_day(455)
    create :disburse, credit_agreement: @credit_agreement, amount: 9467, date: Date.today.prev_day(390)
    create :deposit, credit_agreement: @credit_agreement, amount: 1111, date: Date.today.prev_day(7)
    create :disburse, credit_agreement: @credit_agreement, amount: 555, date: Date.today.prev_day(2)
    @credit_agreement.reload
    expect(@credit_agreement.todays_total).to eq(
      @credit_agreement.auto_balances.build(date: Date.today).end_amount 
    )
  end

  it "total_interest" do
    @credit_agreement = create :credit_agreement, amount: 2000, interest_rate: 2 
    create :deposit, credit_agreement: @credit_agreement, amount: 23456, date: Date.today.prev_day(455)
    create :disburse, credit_agreement: @credit_agreement, amount: 9467, date: Date.today.prev_day(390)
    create :deposit, credit_agreement: @credit_agreement, amount: 1111, date: Date.today.prev_day(7)
    create :disburse, credit_agreement: @credit_agreement, amount: 555, date: Date.today.prev_day(2)
    @credit_agreement.reload
    expect(@credit_agreement.total_interest).to eq(
      (@credit_agreement.balances.to_a + [@credit_agreement.send(:todays_balance)]).sum(&:interests_sum)
    )
  end

  it "balances are sorted by date ascending" do
    @credit_agreement = create :credit_agreement
    create :balance, credit_agreement: @credit_agreement, date: Date.today
    create :balance, credit_agreement: @credit_agreement, date: Date.today - 2.years
    create :balance, credit_agreement: @credit_agreement, date: Date.today - 1.years
    expected_order = [Date.today - 2.years, Date.today - 1.years, Date.today]
    expect(@credit_agreement.balances.pluck(:date)).to eq(expected_order)
  end

  it "not active if it has no payments" do
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

  it "termination date is nil by default" do
    @credit_agreement = create :credit_agreement
    expect(@credit_agreement.terminated_at).to be_nil
  end

  it "is not terminated if no termination date is set" do
    @credit_agreement = build :credit_agreement
    expect(@credit_agreement).not_to be_terminated
  end

  it "is terminated if termination date is set" do
    @credit_agreement = build :credit_agreement, terminated_at: Date.today
    expect(@credit_agreement).to be_terminated
  end

  it "on being terminated, it calls the Terminator" do
    @credit_agreement = create :credit_agreement
    allow_any_instance_of(CreditAgreementTerminator).to receive(:terminate).and_return(true)
    expect(CreditAgreementTerminator).to receive(:new).with(@credit_agreement).and_call_original
    expect_any_instance_of(CreditAgreementTerminator).to receive(:terminate).with(no_args)
    @credit_agreement.update(terminated_at: Date.today)
  end

  it "does not call the terminator, if it is allready terminated" do
    @credit_agreement = create :credit_agreement
    create :deposit, credit_agreement: @credit_agreement
    @credit_agreement.update_column(:terminated_at, Date.today)
    expect(CreditAgreementTerminator).not_to receive(:new)
    @credit_agreement.reload.save
  end
end
  
