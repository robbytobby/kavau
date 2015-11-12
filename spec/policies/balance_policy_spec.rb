require 'rails_helper'

RSpec.describe BalancePolicy do
  context "automatic created balances" do
    subject { BalancePolicy.new(user, balance) }
    let(:balance) { FactoryGirl.create(:balance) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :show, :new, :create, :edit, :update]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :show, :new, :create, :edit, :update]
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits :none
    end
  end

  context "manually_edited balances" do
    subject { BalancePolicy.new(user, balance) }
    let(:balance) { FactoryGirl.create(:balance, manually_edited: true, end_amount: 10000) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits :none
    end
  end

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
end

