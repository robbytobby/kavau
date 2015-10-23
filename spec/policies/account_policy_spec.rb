require 'rails_helper'

[:organization_account, :person_account, :project_account].each do |type|
  RSpec.describe AccountPolicy do
    subject { AccountPolicy.new(user, account) }
    let(:account) { FactoryGirl.create(type) }

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
end

RSpec.describe AccountPolicy do
  let(:user){ create :admin }

  it "a project account with credit_agreements cannot be deleted" do
    account = create :project_account
    create :credit_agreement, account: account
    expect(AccountPolicy.new(user, account).destroy?).to be_falsy
  end
end
