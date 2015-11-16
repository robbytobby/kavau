require 'rails_helper'

RSpec.describe ManualBalancePolicy do
  subject { ManualBalancePolicy.new(user, balance) }
  let(:balance) { FactoryGirl.create(:manual_balance, end_amount: 10000) }

  it_behaves_like "balance_policy"

  context "for an admin" do
    let(:user){ create :admin }
    permits :all
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits :all
  end
end

