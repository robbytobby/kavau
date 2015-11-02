require 'rails_helper'

RSpec.describe DisbursePolicy do
  subject { DisbursePolicy.new(user, payment) }
  let(:payment) { FactoryGirl.create(:disburse) }

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
end

