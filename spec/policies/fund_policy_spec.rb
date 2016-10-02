require 'rails_helper'

RSpec.describe FundPolicy do
  subject { FundPolicy.new(user, fund) }
  let(:fund) { create(:fund) }
  
  context "for an admin" do
    let(:user){ create :admin }
    permits [:new, :create, :edit, :update, :delete, :destroy]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:new, :create, :edit, :update, :delete, :destroy]
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end

  context "a fund with credit agreements" do
    before(:each){
      project = create :project_address, :with_default_account
      @fund = create :fund, project_address: project
      create :credit_agreement, account: project.accounts.first, interest_rate: @fund.interest_rate
    }
    let(:fund){ @fund }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:new, :create] 
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:new, :create] 
    end

    context "for a non privileged user" do
      let(:user){ create :user }
      permits :none
    end
  end
end
