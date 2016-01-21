require 'rails_helper'

RSpec.describe BalanceUpdater, type: :model do

  ['2013-1-1', '2013-6-6', '2013-12-31', '2014-1-1', '2014-6-6', '2014-12-13'].each do |date|
    it "updates existing balances if a payment changes in amount- payment_date: #{date}" do
      @credit_agreement = create :credit_agreement, interest_rate: 1
      @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
      @updater = BalanceUpdater.new(@credit_agreement)
      old_end_amounts = @credit_agreement.auto_balances.map(&:end_amount)
      @deposit.update_column(:amount, 2000)
      @updater.run
      expect(@credit_agreement.balances.reload.map(&:end_amount)).not_to include(*old_end_amounts)
    end
  end

  context "I do not care for balances end_amount" do
    before :each do
      allow_any_instance_of(Balance).to receive(:start_amount).and_return(1)
      allow_any_instance_of(Balance).to receive(:end_amount).and_return(2)
    end

    (1..10).each do |number|
      it "creates obligatory balances on payment date change" do
        @credit_agreement = create :credit_agreement, interest_rate: 1
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today
        @updater = BalanceUpdater.new(@credit_agreement)
        
        @deposit.update_column(:date, @deposit.date.prev_year(number))
        expect{
          @updater.run
        }.to change(@credit_agreement.balances, :count).by(number)
      end
    end

    (1..10).each do |number|
      it "deletes unnecessary balances on payment date change" do
        @credit_agreement = create :credit_agreement, interest_rate: 1
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.prev_year(10)
        @updater = BalanceUpdater.new(@credit_agreement)
        
        @deposit.update_column(:date, @deposit.date.next_year(number))
        expect{
          @updater.run
        }.to change(@credit_agreement.balances, :count).by(-number)
      end
    end

    [ Date.today.beginning_of_year.prev_year(3), 
      Date.today.beginning_of_year.prev_year(3).next_month(1).next_day(2), 
      Date.today.end_of_year.prev_year(3)
    ].each do |date|
      it "deletes unnecessary blance when a payment is created or deleted" do
        @credit_agreement = create :credit_agreement
        create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.today.prev_year
        expect(@credit_agreement.reload.balances.count).to eq(1)
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: date
        expect(@credit_agreement.reload.balances.reload.count).to eq(3)
        @deposit.destroy
        expect(@credit_agreement.reload.balances.reload.count).to eq(1)
        end
      end

    [ Date.today.beginning_of_year.prev_year(11), 
      Date.today.beginning_of_year.prev_year(2).next_month(1).next_day(2), 
      Date.today.end_of_year.prev_year(1),
      Date.today.beginning_of_year
    ].each do |date|
      it "does not delete the necessary balances when payments are deleted" do
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
