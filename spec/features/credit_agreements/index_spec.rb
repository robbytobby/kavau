require 'rails_helper'

RSpec.describe "credit agreements index" do
  include ActionView::Helpers::NumberHelper
  context "as unpriviledged user" do
    before(:each){ login_as create(:user) }

    it "shows the credit agreements index" do
      visit "/"
      click_on 'credit_agreements_index'
      expect(current_path).to eq(credit_agreements_path)
    end

    it "shows credits without creditor name and without edit and delete links"  do
      @credit_agreement = create :credit_agreement
      visit credit_agreements_path
      expect(page).to have_content(number_to_currency(@credit_agreement.amount))
      expect(page).to have_content(@credit_agreement.account.name)
      expect(page).to have_content(number_to_percentage(@credit_agreement.interest_rate))
      expect(page).to_not have_content(@credit_agreement.creditor.name)
      expect(page).to_not have_content(@credit_agreement.creditor.first_name)
      expect(page).to_not have_css("a#edit_credit_agreement_#{@credit_agreement.id}")
      expect(page).to_not have_css("a#delete_credit_agreement_#{@credit_agreement.id}")
    end
  end

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(:accountant) }

      it "shows the credit agreements index" do
        visit "/"
        click_on 'credit_agreements_index'
        expect(current_path).to eq(credit_agreements_path)
      end

      it "shows credits with creditor and links"  do
        @credit_agreement = create :credit_agreement
        visit credit_agreements_path
        expect(page).to have_content(number_to_currency(@credit_agreement.amount))
        expect(page).to have_content(@credit_agreement.account.name)
        expect(page).to have_content(number_to_percentage(@credit_agreement.interest_rate))
        expect(page).to have_content(@credit_agreement.creditor.name)
        expect(page).to have_content(@credit_agreement.creditor.first_name)
        expect(page).to have_css("a#edit_credit_agreement_#{@credit_agreement.id}")
        expect(page).to have_css("a#delete_credit_agreement_#{@credit_agreement.id}")
      end
    end
  end
end
