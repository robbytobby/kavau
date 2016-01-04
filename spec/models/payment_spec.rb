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

  describe "a change also changes associated balances" do
    ['2013-1-1', '2013-6-6', '2013-12-31', '2014-1-1', '2014-6-6', '2014-12-13'].each do |date|
      it "updates existing balances on being changed - payment_date: #{date}" do
        @credit_agreement = create :credit_agreement, interest_rate: 1
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
        @balance = @credit_agreement.balances.find_by(date: Date.strptime(date).end_of_year)
        interest = 0.01 * 1000 * (Date.strptime(date).end_of_year - Date.strptime(date)) / Date.strptime(date).end_of_year.yday
        expect(@balance.end_amount).to eq(1000 + interest.round(2))
        old_end_amount = @balance.end_amount
        @deposit.update(amount: 2000)
        interest = 0.01 * 2000 * (Date.strptime(date).end_of_year - Date.strptime(date)) / Date.strptime(date).end_of_year.yday
        expect(@balance.reload.end_amount).to eq(2000 + interest.round(2))
      end
    end

    context "date change" do
      (1..10).each do |number|
        before(:each){ @year = Date.today.year }

        it "by -#{number} years" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today
          @deposit.update_column(:date, Date.new(@year, 10, 31))
          expect(@credit_agreement.reload.balances.count).to eq(0)
          @deposit.update(date: @deposit.date - number.years)
          expect(@credit_agreement.reload.balances.count).to eq(number)
          expect(@credit_agreement.reload.balances.order(:date).pluck(:date)).to eq(balance_dates(*((@year - number)...@year).to_a ))
        end

        it "by #{number} years" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.new(@year - 10, 1, 1)
          expect(@credit_agreement.reload.balances.count).to eq(10)
          @deposit.update(date: @deposit.date + number.years)
          expect(@credit_agreement.reload.balances.count).to eq(10 - number)
          expect(@credit_agreement.reload.balances.order(:date).pluck(:date)).to eq(balance_dates(*((@year - 10 + number)...@year).to_a ))
        end
      end
      
      it "changing twice by -5 years" do
        allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
        @credit_agreement = create :credit_agreement
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today
        expect(@credit_agreement.reload.balances.count).to eq(0)
        @deposit.update(date: @deposit.date - 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(5)
        @deposit.update(date: @deposit.date - 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(10)
      end

      it "changing twice by +5 years" do
        allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
        @credit_agreement = create :credit_agreement
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.prev_year(10)
        expect(@credit_agreement.reload.balances.count).to eq(10)
        @deposit.update(date: @deposit.date + 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(5)
        @deposit.update(date: @deposit.date + 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(0)
      end

      [ Date.today.beginning_of_year.prev_year(3), 
        Date.today.beginning_of_year.prev_year(3).next_month(1).next_day(2), 
        Date.today.end_of_year.prev_year(3)
      ].each do |date|
        it "deleting a payment also deletes unnecessary blances" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.prev_year
          expect(@credit_agreement.reload.balances.count).to eq(1)
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
          expect(@credit_agreement.reload.balances.count).to eq(3)
          @deposit.destroy
          expect(@credit_agreement.reload.balances.count).to eq(1)
        end
      end

      [ Date.today.beginning_of_year.prev_year(11), 
        Date.today.beginning_of_year.prev_year(2).next_month(1).next_day(2), 
        Date.today.end_of_year.prev_year(1),
        Date.today.beginning_of_year
      ].each do |date|
        it "does not delete the necessary balances while being deleted" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.prev_year
          expect(@credit_agreement.balances.count).to eq(1)
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
          @deposit.destroy
          expect(@credit_agreement.balances.count).to eq(1)
        end
      end
    end
  end

  def balance_dates(*years)
    years.map{ |y| Date.new(y).end_of_year }
  end
end
