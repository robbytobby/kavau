require 'rails_helper'

RSpec.describe Payment, type: :model do
  it "valid types are disburse and deposit" do
    expect(Payment.valid_types).to eq(["Deposit", "Disburse"])
  end

  it "updates existing older balances on being changed" do
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2014-12-31'
    @balance = @credit_agreement.balances.create(date: Date.new(2014,12,31))
    expect(@balance.end_amount).to eq(1000)
    expect(@balance).to be_persisted
    @deposit.update(amount: 2000)
    expect(@balance.reload.end_amount).to eq(2000)
  end
end
