require 'rails_helper'

RSpec.describe SettingPolicy do
  subject { SettingPolicy.new(user, setting) }
  let(:setting) { FactoryBot.create(:setting) }

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

  describe "permitted params" do
    let(:user){ create :admin }

    it "premitted params are [:value]" do
      expect(subject.permitted_params).to eq [:value]
    end
  end
end

