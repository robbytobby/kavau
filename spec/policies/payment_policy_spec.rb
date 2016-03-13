require 'rails_helper'

[:deposit, :disburse].each do |payment_type|
  RSpec.describe PaymentPolicy do
    subject { PaymentPolicy.new(user, payment) }
    let(:payment) { FactoryGirl.create(payment_type) }

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
        permits [:index, :show, :download]
      end

      context "for an accountant" do
        let(:user){ create :accountant }
        permits [:index, :show, :download]
      end

      context "for a non privileged user" do
        let(:user){ create :user }
        permits [:index, :show]
      end
    end
  end
end

