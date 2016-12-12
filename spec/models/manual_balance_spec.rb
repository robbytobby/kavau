require 'rails_helper'

RSpec.describe ManualBalance, type: :model do
  before :each do
    allow_any_instance_of(Deposit).to receive(:not_before_credit_agreement_starts).and_return(true)
    @credit_agreement = create :credit_agreement, interest_rate: 2, amount: 20000
  end

  it_behaves_like "balance" 

  describe "end_amount" do
    it "does not update end_amount upon payment changes" do
      @deposit = create_deposit Date.today, 5000
      @balance = @credit_agreement.auto_balances.create(date: Date.today)
      expect(@balance.end_amount).to eq(5000)
      @balance.becomes_manual_balance.save
      @credit_agreement.reload
      @balance = Balance.find(@balance.id)
      @deposit.update(amount: 2000)
      expect(@balance.reload.end_amount).to eq(5000)
    end

    it "is not updated if previous balance changes" do
      @deposit = create_deposit Date.today.end_of_year.prev_year(2), 5000
      expect(@credit_agreement.reload.balances.count).to eq(2)
      @balance_1, @balance_2 = @credit_agreement.balances.order(:date)
      @balance_1.becomes_manual_balance.save
      @balance_2.becomes_manual_balance.save
      @balance_1 = Balance.find(@balance_1.id)
      @balance_2 = Balance.find(@balance_2.id)
      @balance_1.update(end_amount: 6000)
      @new_balance_1, @new_balance_2 = @credit_agreement.balances.order(:date)
      expect(@new_balance_1.end_amount).to eq(6000)
      expect(@new_balance_2.end_amount).to eq(@balance_2.end_amount)
    end
  end

  it "interests sum is calculated from end_amount" do
    create_deposit '2014-12-1', 10000
    create_disburse '2014-12-1', 1000
    @balance = balance '2014-12-31', 9020
    expect(@balance.interests_sum).to eq(20)
  end

  it "has only one interest span independent of the number of payments" do
    create_deposit '2014-10-1', 10000
    create_deposit '2014-12-1', 10000
    @balance = balance '2014-12-31'
    expect(@balance.send(:interest_spans).count).to eq(1)
  end

  def balance(date = Date.today, end_amount = 2000)
    ManualBalance.find_or_create_by(credit_agreement_id: @credit_agreement.id, date: date, end_amount: end_amount)
  end

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end

end
