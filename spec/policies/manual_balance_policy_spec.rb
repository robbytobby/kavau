require 'rails_helper'

RSpec.describe ManualBalancePolicy do
  subject { ManualBalancePolicy.new(user, balance) }
  let(:balance) { FactoryGirl.create(:manual_balance, end_amount: 10000) }

  it_behaves_like "balance_policy"

  context "for an admin" do
    let(:user){ create :admin }
    permits [:edit, :update, :destroy]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:edit, :update, :destroy]
  end

  context "of terminated credit agreement" do
    before(:each){ allow_any_instance_of(CreditAgreement).to receive(:terminated?).and_return(true) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :none
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :none
    end
  end
end

