require 'rails_helper'

RSpec.describe Payment, type: :model do
  it "valid types are disburse and deposit" do
    expect(Payment.valid_types.sort).to eq(["Deposit", "Disburse"])
  end

  it "future payments are invalid" do
    @disburse = build :disburse, date: Date.tomorrow
    @deposit = build :deposit, date: Date.tomorrow
    expect(@disburse).not_to be_valid
    expect(@deposit).not_to be_valid
    expect(@disburse.errors.messages[:date].first).to eq('darf nicht in der Zukunft liegen')
    expect(@deposit.errors.messages[:date].first).to eq('darf nicht in der Zukunft liegen')
  end

  it "payments for a terminated year are invalid" do
    allow_any_instance_of(BalanceLetter).to receive(:to_pdf).and_return(true)
    @credit_agreement = create :credit_agreement, interest_rate: 1
    @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.prev_year
    @letter = create :balance_letter, year: Date.today.prev_year.year
    create :pdf, letter: @letter, creditor: @credit_agreement.creditor
    @credit_agreement.reload
    @deposit = build :deposit, credit_agreement: @credit_agreement, date: Date.today.prev_year
    @disburse = build :disburse, credit_agreement: @credit_agreement, date: Date.today.prev_year
    expect(@deposit).not_to be_valid
    expect(@disburse).not_to be_valid
  end

  it "delegates year_terminated? to credit agreement" do
    @credit_agreement = create :credit_agreement
    @deposit = build :deposit, credit_agreement: @credit_agreement
    allow(@credit_agreement).to receive(:year_terminated?).and_return(true)
    @deposit.year_terminated?
    expect(@credit_agreement).to have_received(:year_terminated?).with(@deposit.date.year)
  end

  describe "triggers update of balances" do
    before :each do
      @credit_agreement = create :credit_agreement
      @deposit = create :deposit, credit_agreement: @credit_agreement
      allow_any_instance_of(BalanceUpdater).to receive(:run).and_return(true)
    end

    it "triggers update of balances on being saved" do
      expect(BalanceUpdater).to receive(:new).with(@credit_agreement).and_call_original
      @deposit.save
    end

    it "triggers update of balances on being destroyed" do
      expect(BalanceUpdater).to receive(:new).with(@credit_agreement).and_call_original
      @deposit.destroy
    end
  end

end
