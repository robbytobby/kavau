require 'rails_helper'

RSpec.describe AutoBalancePolicy do
  subject { AutoBalancePolicy.new(user, balance) }
  let(:balance) { FactoryGirl.create(:balance) }

  it_behaves_like "balance_policy"

  context "for an admin" do
    let(:user){ create :admin }
    permits [:index, :show, :new, :create, :edit, :update]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:index, :show, :new, :create, :edit, :update]
  end
end

