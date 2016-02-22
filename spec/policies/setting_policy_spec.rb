require 'rails_helper'

RSpec.describe SettingPolicy do
  subject { SettingPolicy.new(user, setting) }
  let(:setting) { FactoryGirl.create(:setting) }

  context "for an Admin" do
    let(:user){ create :admin }
    permits :all, except: [:show, :new, :edit, :create]
  end
  
  [:accountant, :user].each do |role|
    context "for a #{role}" do
      let(:user){ create role }
      permits :none
    end
  end
  
end

