require 'rails_helper'

RSpec.describe AddressPolicy do
  subject { AddressPolicy.new(user, address) }
  let(:address) { FactoryGirl.create(:address) }

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
