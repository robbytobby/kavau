require 'rails_helper'

RSpec.describe ContactPolicy do
  subject { ContactPolicy.new(user, address) }
  let(:address) { FactoryBot.create(:contact) }

  context "for an admin" do
    let(:user){ create :admin }
    permits [:new, :create, :edit, :update, :destroy, :delete]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:new, :create, :edit, :update, :destroy, :delete]
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end
end

