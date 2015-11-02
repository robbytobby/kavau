require 'rails_helper'
RSpec.describe ApplicationPolicy do
  subject { ApplicationPolicy.new(user, record) }
  let(:record) { FactoryGirl.create(:contact) }

  context "for an admin" do
    let(:user){ create :admin }
    permits [:show]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits [:show] 
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end
end

