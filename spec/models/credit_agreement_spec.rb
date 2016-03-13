require 'rails_helper'

RSpec.describe CreditAgreement, type: :model do
  context "as spreadsheet" do
    it "is convertable to spreadsheet" do
      credit_agreement = create :credit_agreement
      expect(credit_agreement.send(:spreadsheet_columns)).to eq(
        [ 
          ["ID", :id],
          ["Nummer", :number],
          ["Betrag [€]", :amount],
          ["Zinssatz p.a. [%]", :interest_rate],
          ["Kündigungsfrist [Monate]", :cancellation_period],
          ["Kreditgeber_in", :presented_creditor_name],
          ["Kreiditgeber_in ID", :creditor_id],
          ["Konto", :presented_account_name],
          ["Konto ID", :account_id],
          ["getilgt am", :presented_terminated_at]
        ]
      )
    end

    let(:object){ create :credit_agreement }
    it_behaves_like "spreadsheet"
  end

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

  describe "versioning" do
    before(:each){ @credit = create :credit_agreement, interest_rate: 1, valid_from: Date.new(2016,1,1) }

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
        it "is saved in the versions metadata" do
          @credit.update_attributes!(valid_from: Date.today)
          expect(@credit.versions.last.valid_from).to eq(Date.new(2016,1,1))
        end

        it "saves valid_until in Metadata" do
          @credit.update_attributes!(valid_from: Date.today)
          expect(@credit.versions.last.valid_until).to eq(Date.today)
        end

        it "the new valid_from date is not allowed to be before the old valid_from_date" do
          @credit_agreement = create :credit_agreement, valid_from: Date.today
          expect(@credit_agreement.update_attributes(valid_from: Date.yesterday)).to be_falsy
          expect(@credit_agreement.errors[:valid_from]).not_to be_empty
        end

        it "valid_from may not be changed to a year, which is allready terminated" do
          @credit_agreement = create :credit_agreement, valid_from: Date.today
          allow_any_instance_of(Creditor).to receive(:year_terminated?).and_return(true)
          expect(@credit_agreement.update_attributes(valid_from: Date.yesterday)).to be_falsy
          expect(@credit_agreement.errors[:valid_from]).not_to be_empty
        end
      end

      describe "change of interest_rate" do
        it "knows that interest rate has not changed" do
          @credit.update_attributes!(valid_from: Date.today)
          expect(@credit.versions.last.interest_rate_changed).to be_falsy
        end

        it "marks the interest_rate change in the version" do
          @credit.update_attributes!(interest_rate: 2)
          expect(@credit.versions.last.interest_rate_changed).to be_truthy
        end
      end

      it "knows its date, when the interest rate changed" do
        @credit_agreement = create :credit_agreement, valid_from: Date.new(2014, 1, 1), interest_rate: 1
        @credit_agreement.update_attributes(interest_rate: 2, valid_from: Date.new(2014, 3, 1))
        @credit_agreement.update_attributes(interest_rate: 1.5, valid_from: Date.new(2015, 2, 1))
        @credit_agreement.update_attributes(interest_rate: 3, valid_from: Date.new(2015, 12, 1))
        expect(@credit_agreement.interest_rate_change_dates_between(Date.new(2014,1,1), Date.today)).to eq([Date.new(2014, 3, 1), Date.new(2015, 2, 1), Date.new(2015, 12,1)])
      end

      describe "interest_rate at a given date" do
        it "interest rate changed once" do
          @credit_agreement = create :credit_agreement, valid_from: Date.new(2015, 1, 1), interest_rate: 5
          @credit_agreement.update_attributes(interest_rate: 2, valid_from: Date.new(2015, 7, 1))
          expect(@credit_agreement.interest_rate).to eq(2)
          expect(@credit_agreement.interest_rate_at(Date.new(2015,1,1))).to eq(5)
          expect(@credit_agreement.interest_rate_at(Date.new(2015,12,15))).to eq(2)
        end

        it "interest rate changed multiple times" do
          @credit_agreement = create :credit_agreement, valid_from: Date.new(2014, 1, 1), interest_rate: 1
          @credit_agreement.update_attributes(interest_rate: 2, valid_from: Date.new(2014, 3, 1))
          @credit_agreement.update_attributes(interest_rate: 1.5, valid_from: Date.new(2015, 2, 1))
          @credit_agreement.update_attributes(interest_rate: 3, valid_from: Date.new(2015, 12, 1))
          expect(@credit_agreement.interest_rate).to eq(3)
          expect(@credit_agreement.interest_rate_at(Date.new(2014,1,1))).to eq(1)
          expect(@credit_agreement.interest_rate_at(Date.new(2014,2,28))).to eq(1)
          expect(@credit_agreement.interest_rate_at(Date.new(2014,3,1))).to eq(2)
          expect(@credit_agreement.interest_rate_at(Date.new(2015,1,31))).to eq(2)
          expect(@credit_agreement.interest_rate_at(Date.new(2015,2,1))).to eq(1.5)
          expect(@credit_agreement.interest_rate_at(Date.new(2015,11,30))).to eq(1.5)
          expect(@credit_agreement.interest_rate_at(Date.new(2015,12,30))).to eq(3)
        end
      end
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
  
