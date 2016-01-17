require 'rails_helper'

RSpec.describe CreditAgreementPolicy do
  context "new credit agreement" do
    let(:klass){ CreditAgreementPolicy}
    subject { CreditAgreementPolicy.new(user, credit_agreement) }
    let(:credit_agreement) { FactoryGirl.create(:credit_agreement) }

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
      permits [:index]
    end
  end

  context "credit_agreement with payments" do
    subject { CreditAgreementPolicy.new(user, credit_agreement) }
    let(:credit_agreement) { FactoryGirl.create(:credit_agreement, :with_payment) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:delete, :destroy]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:delete, :destroy]
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits [:index]
    end
  end
end
