require 'rails_helper'

RSpec.describe DepositPolicy do
  subject { DepositPolicy.new(user, payment) }
  let(:payment) { FactoryGirl.create(:deposit) }

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
    permits [:index, :show]
  end

  context "for a terminated credit_agreement" do
    before(:each){ allow_any_instance_of(CreditAgreement).to receive(:terminated?).and_return(true) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :show, :download, :download_csv]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :show, :download, :download_csv]
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits [:index, :show]
    end
  end

  context "for a terminated year" do
    before(:each){ allow_any_instance_of(CreditAgreement).to receive(:year_terminated?).and_return(true) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :new, :create, :show, :download, :download_csv]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :new, :create, :show, :download, :download_csv]
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits [:index, :show]
    end
  end
end

