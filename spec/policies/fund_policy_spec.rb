require 'rails_helper'

RSpec.describe FundPolicy do
  subject { FundPolicy.new(user, fund) }
  let(:fund) { create(:fund) }
  
  context "for an admin" do
    let(:user){ create :admin }
    permits [:new, :create, :edit, :update, :delete, :destroy]
  end

  context "for an admin" do
    let(:user){ create :admin }
    permits [:new, :create, :edit, :update, :delete, :destroy]
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end
end
