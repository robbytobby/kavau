require 'rails_helper'

RSpec.describe PersonPolicy do
  subject { PersonPolicy.new(user, address) }
  let(:address) { FactoryBot.create(:person) }

  it_behaves_like "address_policy"

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      let(:user){ create type }

      it "may not be destroyed if it has credits" do
        @person = create :person
        create :credit_agreement, creditor: @person
        
        expect(PersonPolicy.new(user, @person).destroy?).to be_falsy
      end
    end
  end
end

