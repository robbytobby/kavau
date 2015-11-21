require 'rails_helper'

class AddressPolicy < ApplicationPolicy
end

RSpec.describe ApplicationPolicy do
  subject { ApplicationPolicy.new(user, record) }
  let(:record) { create :address }

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

  [:user, :accountant, :admin].each do |type|
    let(:user){ create type }
    it "permitted params are empty" do
      expect(ApplicationPolicy.new(user, record).permitted_params).to eq([])
    end

    it "scope is none" do
      expect(ApplicationPolicy.new(user, record).scope).to eq(Address)
    end
  end
end

