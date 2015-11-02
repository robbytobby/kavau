require 'rails_helper'

RSpec.describe "managing credit agreements" do
  include ActionView::Helpers::NumberHelper

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      before :each do
        login_as create(type)
        @credit_agreement = create :credit_agreement
      end

      it "I can go to the credit agreement from credit agreements index" do
        visit '/credit_agreements'
        click_on "show_credit_agreement_#{@credit_agreement.id}"
        expect(current_path).to eq(credit_agreement_path(@credit_agreement))
      end

      it "I can go to the credit agreement from creditors page " do
        visit model_path(@credit_agreement.creditor)
        click_on "show_credit_agreement_#{@credit_agreement.id}"
        expect(current_path).to eq(credit_agreement_path(@credit_agreement))
      end

      it "the credit agreement page show the basic data" do
        visit credit_agreement_path(@credit_agreement)
        expect(page).to have_content(@credit_agreement.id)
        expect(page).to have_content(@credit_agreement.creditor.name)
        expect(page).to have_content(number_to_currency(@credit_agreement.amount))
        expect(page).to have_content(number_to_percentage(@credit_agreement.interest_rate))
        expect(page).to have_content(@credit_agreement.cancellation_period)
      end
    end
  end

  def model_path(address)
    send("#{address.type.underscore}_path", address)
  end
end

