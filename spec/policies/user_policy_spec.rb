require 'rails_helper'

RSpec.describe UserPolicy do
  subject { UserPolicy.new(user, test_user) }
  let(:test_user) { FactoryGirl.create(:user) }

  context "for an admin" do
    let(:user){ create :admin }
    permits :all
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits :none 
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end

  context "for own account" do
    context "for an accountant" do
      let(:user){ create :accountant }
      subject { UserPolicy.new(user, user) }
      permits [:edit, :update]
    end

    context "for an account" do
      let(:user){ create :user }
      subject { UserPolicy.new(user, user) }
      permits [:edit, :update]
    end
  end
end
