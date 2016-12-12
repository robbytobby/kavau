require 'rails_helper'

RSpec.describe TerminationBalance, type: :model do
  before :each do
    allow_any_instance_of(TerminationLetter).to receive(:to_pdf).and_return true
    allow_any_instance_of(Deposit).to receive(:not_before_credit_agreement_starts).and_return(true) 
    create :termination_letter
    @credit_agreement = create :credit_agreement, interest_rate: 2
  end

  it "reopens the credit_agreement on being deleted" do
    create :deposit, credit_agreement: @credit_agreement, date: Date.yesterday, amount: 2000
    @credit_agreement.terminated_at = Date.today
    @credit_agreement.save
    @credit_agreement.termination_balance.destroy
    expect(@credit_agreement.reload).not_to be_terminated
  end

  it "has an end_amount of 0" do
    create :deposit, credit_agreement: @credit_agreement, date: Date.yesterday, amount: 2000
    @credit_agreement.terminated_at = Date.today
    @credit_agreement.save
    expect(@credit_agreement.termination_balance.end_amount).to eq(0)
  end
end

