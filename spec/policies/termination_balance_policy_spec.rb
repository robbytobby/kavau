require 'rails_helper'

RSpec.describe TerminationBalancePolicy do
  subject { TerminationBalancePolicy.new(user, balance) }
  let(:balance) { FactoryGirl.create(:balance) }

  it_behaves_like "balance_policy"

  context "for an admin" do
    let(:user){ create :admin }
    permits [:destroy]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:destroy]
  end
end

