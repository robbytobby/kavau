require 'rails_helper'

RSpec.describe TerminationBalance, type: :model do
  before :each do
    create :termination_letter
    @project_address = create :complete_project_address
    @credit_agreement = create :credit_agreement, interest_rate: 2, account: @project_address.default_account
  end

  it "end_amount is allways 0" do
    create_deposit Date.today, 5000
    create_disburse Date.today, 2000
    expect(balance.end_amount).to eq(0)
  end

  it "creates a disburse on being saved" do
    create_deposit Date.today.prev_year(2).end_of_year, 5000
    expect{
      TerminationBalance.create(credit_agreement_id: @credit_agreement.id, date: Date.today.prev_year.end_of_year)
    }.to change(@credit_agreement.payments, :count).by(1)
    expect(@credit_agreement.payments.last).to be_a(Disburse)
    expect(@credit_agreement.payments.last.date).to eq(Date.today.prev_year.end_of_year)
    expect(@credit_agreement.payments.last.amount).to eq(5100)
  end

  it "deletes the last corresponding disburse on being deleted" do
    create_deposit Date.today.prev_year(2).end_of_year, 5000
    @balance = TerminationBalance.create(credit_agreement_id: @credit_agreement.id, date: Date.tomorrow)
    expect{
      @balance.destroy
    }.to change(@credit_agreement.payments.reload, :count).by(-1)
  end

  it "reopens the credit_agreement on being deleted" do
    create_deposit Date.today.prev_year(2).end_of_year, 5000
    @balance = balance
    @balance.destroy
    expect(@credit_agreement).not_to be_terminated
  end



  def balance(date = Date.today)
    TerminationBalance.find_or_create_by(credit_agreement_id: @credit_agreement.id, date: date)
  end

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end
end

