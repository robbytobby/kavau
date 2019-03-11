require 'rails_helper'

RSpec.describe TerminationBalancePolicy do
  subject { TerminationBalancePolicy.new(user, balance) }
  let(:balance) { FactoryBot.create(:balance) }

  it_behaves_like "balance_policy"

  context "for an admin" do
    let(:user){ create :admin }
    permits [:show, :destroy, :delete, :download]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:show, :destroy, :delete, :download]
  end
end

