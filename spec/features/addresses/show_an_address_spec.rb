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

      [:standard_letter, :balance_letter].each do |letter_type|
        it "shows the pdfs" do
          letter = create letter_type, year: 2014
          create :complete_project_address, legal_form: 'registered_society'
          @address.pdfs.create(letter: letter)
          visit send("#{type}_path", @address)
          within 'div.pdfs' do
            expect(page).to have_content(I18n.l(Date.today))
            expect(page).to have_content(letter.subject) if letter_type == :standard_letter
            expect(page).to have_content('Jahresbilanz 2014') if letter_type == :balance_letter
            expect(page).to have_link('', href: "/pdfs/#{@address.pdfs.first.id}.pdf")
            expect(page).to have_selector("a[href='/pdfs/#{@address.pdfs.first.id}'][data-method='put']")
            expect(page).to have_selector("a[href='/pdfs/#{@address.pdfs.first.id}'][data-method='delete']")
          end
        end
      end

      it "shows termination_letter pdfs" do
        @balance = create :termination_balance, credit_agreement: @credit_agreement, creditor: @address
        visit send("#{type}_path", @address)
        within 'div.pdfs' do
          expect(page).to have_content(I18n.l(Date.today))
          expect(page).to have_content('Kündigungs-Schreiben')
          expect(page).to have_link('', href: "/pdfs/#{@address.pdfs.first.id}.pdf")
          expect(page).to have_selector("a[href='/pdfs/#{@address.pdfs.first.id}'][data-method='put']")
          expect(page).not_to have_selector("a[href='/pdfs/#{@address.pdfs.first.id}'][data-method='delete']")
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
