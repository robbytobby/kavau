require 'rails_helper'

RSpec.describe Payment, type: :model do
  it "valid types are disburse and deposit" do
    expect(Payment.valid_types).to eq(["Deposit", "Disburse"])
  end

  describe "a change also changes associated balances" do
    ['2013-1-1', '2013-6-6', '2013-12-31', '2014-1-1', '2014-6-6', '2014-12-13'].each do |date|
      it "updates existing balances on being changed - payment_date: #{date}" do
        @credit_agreement = create :credit_agreement
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
        @balance = @credit_agreement.balances.find_by(date: Date.strptime(date).end_of_year)
        old_end_amount = @balance.end_amount
        @deposit.update(amount: 2000)
        expect(@balance.reload.end_amount - old_end_amount).to eq(1000)
      end
    end

    context "date change" do
      (1..10).each do |number|
        it "by -#{number} years" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2015-10-31'
          expect(@credit_agreement.reload.balances.count).to eq(0)
          @deposit.update(date: @deposit.date - number.years)
          expect(@credit_agreement.reload.balances.count).to eq(number)
          expect(@credit_agreement.reload.balances.order(:date).pluck(:date)).to eq(balance_dates(*((2015 - number)...2015).to_a ))
        end

        it "by #{number} years" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2005-10-31'
          expect(@credit_agreement.reload.balances.count).to eq(10)
          @deposit.update(date: @deposit.date + number.years)
          expect(@credit_agreement.reload.balances.count).to eq(10 - number)
          expect(@credit_agreement.reload.balances.order(:date).pluck(:date)).to eq(balance_dates(*((2005 + number)...2015).to_a ))
        end
      end
      
      it "changing twice by -5 years" do
        allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
        @credit_agreement = create :credit_agreement
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2017-11-15'
        expect(@credit_agreement.reload.balances.count).to eq(0)
        @deposit.update(date: @deposit.date - 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(3)
        @deposit.update(date: @deposit.date - 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(8)
      end

      it "changing twice by +5 years" do
        allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
        @credit_agreement = create :credit_agreement
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2007-11-15'
        expect(@credit_agreement.reload.balances.count).to eq(8)
        @deposit.update(date: @deposit.date + 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(3)
        @deposit.update(date: @deposit.date + 5.years)
        expect(@credit_agreement.reload.balances.count).to eq(0)
      end

      ['2012-1-1', '2012-2-3', '2012-12-31'].each do |date|
        it "deleting a payment also deletes unnecessary blances" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2014-11-15'
          expect(@credit_agreement.reload.balances.count).to eq(1)
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
          expect(@credit_agreement.reload.balances.count).to eq(3)
          @deposit.destroy
          expect(@credit_agreement.reload.balances.count).to eq(1)
        end
      end

      ['2004-1-1', '2013-2-3', '2014-12-31', '2015-1-1'].each do |date|
        it "does not delete the necessary balances while being deleted" do
          allow_any_instance_of(CreditAgreement).to receive(:update_balances).and_return(true)
          @credit_agreement = create :credit_agreement
          create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2014-11-15'
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
