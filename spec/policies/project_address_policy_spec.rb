require 'rails_helper'

RSpec.describe ProjectAddressPolicy do
  subject { ProjectAddressPolicy.new(user, address) }
  let(:address) { FactoryBot.create(:project_address) }

  it_behaves_like "address_policy"

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      let(:user){ create type }

      it "may not be destroyed if it has accounts with credits" do
        @project_address = create :project_address
        @account = create :project_account, address: @project_address
        create :credit_agreement, account: @account
        
        expect(ProjectAddressPolicy.new(user, @project_address).destroy?).to be_falsy

      end
    end
  end
end

