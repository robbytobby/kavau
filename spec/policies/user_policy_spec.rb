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

  context "for own accountant account" do
    context "for an accountant" do
      let(:user){ create :accountant }
      subject { UserPolicy.new(user, user) }
      permits [:edit, :update]
    end

    context "for own user account" do
      let(:user){ create :user }
      subject { UserPolicy.new(user, user) }
      permits [:edit, :update]
    end
  end

  describe "permitted params for an admin" do
    let(:user){ create :admin }

    it "for an admin" do
      expect(UserPolicy.new(user, subject).permitted_params.sort).to eq([:email, :first_name, :login, :name, :password, :password_confirmation, :phone, :role])
    end
  end

  describe "permitted params for an accountant" do
    let(:user){ create :accountant }

    it "for an accountant" do
      expect(UserPolicy.new(user, subject).permitted_params).to eq([:login, :password, :password_confirmation, :first_name, :name, :email, :phone])
    end
  end

  describe "permitted params for an user " do
    let(:user){ create :user }

    it "for an user" do
      expect(UserPolicy.new(user, subject).permitted_params).to eq([:login, :password, :password_confirmation, :first_name, :name, :email, :phone])
    end
  end
end
