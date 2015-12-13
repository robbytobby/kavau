require 'rails_helper'

RSpec.describe "Payments" do
  [:admin, :accountant].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(type) }

      it "has a index page" do
        creditor = create :person
        credit_agreement = create :credit_agreement, creditor: creditor
        disburse = create :disburse, credit_agreement: credit_agreement
        deposit = create :deposit, credit_agreement: credit_agreement
        presented_creditor = PersonPresenter.new(creditor, nil)

        visit '/'
        click_on :payments_index
        expect(current_path).to eq(payments_path)
        [disburse, deposit].each do |payment|
          model = payment.model_name.name.underscore
          within "tr##{model}_#{payment.id}" do
            expect(page).to have_link(credit_agreement.id, href: "/credit_agreements/#{credit_agreement.id}")
            expect(page).to have_link(presented_creditor.full_name, href: "/people/#{creditor.id}")
            expect(page).to have_css("a#edit_#{model}_#{payment.id}")
            expect(page).to have_css("a#delete_#{model}_#{payment.id}")
          end
        end
      end
    end
  end

  context "as unprivileged user" do
    it "has a index page without some information" do
      login_as create :user
      creditor = create :person
      credit_agreement = create :credit_agreement, creditor: creditor
      disburse = create :disburse, credit_agreement: credit_agreement
      deposit = create :deposit, credit_agreement: credit_agreement
      presented_creditor = PersonPresenter.new(creditor, nil)

      visit '/'
      click_on :payments_index
      expect(current_path).to eq(payments_path)
      [disburse, deposit].each do |payment|
        model = payment.model_name.name.underscore
        within "tr##{model}_#{payment.id}" do
          expect(page).not_to have_link(credit_agreement.id, href: "/credit_agreements/#{credit_agreement.id}")
          expect(page).not_to have_content(presented_creditor.full_name)
          expect(page).not_to have_css("a#edit_#{model}_#{payment.id}")
          expect(page).not_to have_css("a#delete_#{model}_#{payment.id}")
        end
      end
    end
  end
end
