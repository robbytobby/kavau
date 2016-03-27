require 'rails_helper'

RSpec.describe Balance, type: :model do
  before :each do
    @credit_agreement = create :credit_agreement, interest_rate: 2
  end

  it_behaves_like "balance"

  it "calculates the amount of deposits" do
    create_deposit(Date.today.prev_year, 1000)
    create_deposit(Date.today.prev_year, 3399)
    expect(balance(Date.today.prev_year.end_of_year).deposits).to eq 4399
  end

  it "calculates the amount of disburses" do
    create_deposit(Date.today.prev_year(2), 10000)
    create_disburse(Date.today.prev_year, 2399)
    create_disburse(Date.today.prev_year, 1000)
    expect(balance(Date.today.prev_year.end_of_year).disburses).to eq 3399
  end

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def balance(date = Date.today)
    @credit_agreement.balances.reload.find_or_create_by(date: date, type: 'AutoBalance')
  end
end
