require 'rails_helper'

RSpec.describe DepositLetterPolicy do
  subject { DepositLetterPolicy.new(user, letter) }
  let(:letter) { FactoryGirl.build(:deposit_letter) }

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

  context "a deposit letter exists" do
    before(:each){ FactoryGirl.create(:deposit_letter) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :show, :update, :edit, :destroy]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :show, :update, :edit, :destroy]
    end

  end
end
