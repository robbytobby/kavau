require 'rails_helper'

RSpec.describe "Address view"  do
  include ActionView::Helpers::NumberHelper
  before(:each){ login_as create(:accountant) }

  [:person, :organization].each do |type|
    describe "for #{type}" do
      before(:each){ @address = create type, notes: 'NOTE', phone: 'PHONE' }

      it "shows the full name" do
        visit send("#{type}_path", @address)
        within 'h1' do
          expect(page).to have_content(@address.name)
          expect(page).to have_content(@address.first_name)
        end
        expect(page).to have_content('NOTE')
        expect(page).to have_content('PHONE')
      end

      it "shows the bank accounts" do
        account = create(:account, address: @address)
        visit send("#{type}_path", @address)
        within 'div.accounts' do
          expect(page).to have_content(account.bank)
          expect(page).to have_content(account.iban)
        end
      end

      it "show the credit agreements" do
        credit_agreement = create(:credit_agreement, creditor: @address) 
        visit send("#{type}_path", @address)
        within 'div.credit_agreements' do
          expect(page).to have_content(credit_agreement.id)
          expect(page).to have_content(credit_agreement.account.name)
          expect(page).to have_content(number_to_currency(credit_agreement.amount))
          expect(page).to have_content(number_to_percentage(credit_agreement.interest_rate))
          expect(page).to have_content(credit_agreement.cancellation_period)
        end
      end
    end
  end

  describe "for project_address" do
    before(:each){ @address = create :project_address, notes: 'NOTE', phone: 'PHONE' }

    it "shows the full name" do
      visit project_address_path(@address)
      within 'h1' do
        expect(page).to have_content(@address.name)
        expect(page).to have_content(@address.first_name)
      end
      expect(page).to have_content('NOTE')
      expect(page).to have_content('PHONE')
    end

    it "shows the bank accounts" do
      account = create(:account, address: @address)
      visit project_address_path(@address)
      within 'div.accounts' do
        expect(page).to have_content(account.bank)
        expect(page).to have_content(account.iban)
      end
    end
  end
end
