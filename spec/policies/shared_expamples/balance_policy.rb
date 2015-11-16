RSpec.shared_examples "balance_policy" do
  context "unsaved balances" do
    subject { BalancePolicy.new(user, balance) }
    let(:balance) { FactoryGirl.build(:balance) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :new, :create]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :new, :create]
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits :none
    end
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end
end

