require 'rails_helper'

RSpec.describe OrganizationPolicy do
  subject { OrganizationPolicy.new(user, address) }
  let(:address) { FactoryBot.create(:organization) }

  it_behaves_like "address_policy"

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      let(:user){ create type }

      it "may not be destroyed if it has credits" do
        @organization = create :organization
        create :credit_agreement, creditor: @organization
        
        expect(OrganizationPolicy.new(user, @organization).destroy?).to be_falsy
      end
    end
  end
end

