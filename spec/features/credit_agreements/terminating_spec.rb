require 'rails_helper'

RSpec.describe "terminating a credit_agreement" do
  include ActionView::Helpers::NumberHelper
  before(:each){ 
    login_as create(:accountant) 
    allow_any_instance_of(Deposit).to receive(:not_before_credit_agreement_starts).and_return(true) 
  }

  before :all do
    create :termination_letter
    @creditor = create :person, name: 'Lincoln', first_name: 'Abraham'
    @project_address = create :complete_project_address, legal_form: 'registered_society'
    @credit_agreement = create :credit_agreement, creditor: @creditor, account: @project_address.default_account
  end

  after :all do
    Letter.delete_all
    Address.delete_all
    CreditAgreement.delete_all
  end
  

  it "is not possible if the credit_agreement does not have payments" do
    visit credit_agreement_path(@credit_agreement)
    expect(page).not_to have_selector('#termination_form')
  end

  context "with payments" do
    before(:each){ create :deposit, credit_agreement: @credit_agreement, date: Date.today.prev_day(32) }

    it "is possible" do
      visit credit_agreement_path(@credit_agreement)
      expect(page).to have_selector('#termination_form')
      termination_date = Date.today.next_day(17)
      select termination_date.mday, from: :credit_agreement_terminated_at_3i
      select I18n.t("date.month_names")[termination_date.month], from: :credit_agreement_terminated_at_2i
      select termination_date.year, from: :credit_agreement_terminated_at_1i
      click_on :terminate
      expect(current_path).to eq(credit_agreement_path(@credit_agreement))
      expect(page).not_to have_selector('#new_payment_form')
      expect(page).not_to have_selector('#termination_form')
      within 'tr.disburse' do
        expect(page).to have_content(I18n.l(termination_date))
      end
      within 'tr.termination_balance' do
        expect(page).to have_content(number_to_currency(0))
      end
      click_on 'Lincoln, Abraham'
      expect(current_path).to eq(person_path(@creditor))
      within "div.pdfs" do
        expect(page).to have_content("Kündigungs-Schreiben")
        expect(page).to have_content("Kreditvertrag #{@credit_agreement.number}")
      end
    end

    it "even if there is another one allready terminated" do
      credit_agreement_old = create :credit_agreement, creditor: @creditor, account: @project_address.default_account, valid_from: Date.today.prev_year, interest_rate: 3
      create :deposit, credit_agreement: credit_agreement_old, date: Date.today.prev_year
      credit_agreement_old.terminated_at = Date.today.prev_month(5)
      credit_agreement_old.save

      visit credit_agreement_path(@credit_agreement)
      expect(page).to have_selector('#termination_form')
      termination_date = Date.today.next_day(17)
      select termination_date.mday, from: :credit_agreement_terminated_at_3i
      select I18n.t("date.month_names")[termination_date.month], from: :credit_agreement_terminated_at_2i
      select termination_date.year, from: :credit_agreement_terminated_at_1i
      click_on :terminate
      expect(@credit_agreement.reload).to be_terminated
      expect(current_path).to eq(credit_agreement_path(@credit_agreement))
      expect(page).not_to have_selector('#new_payment_form')
      expect(page).not_to have_selector('#termination_form')
      within 'tr.disburse' do
        expect(page).to have_content(I18n.l(termination_date))
      end
      within 'tr.termination_balance' do
        expect(page).to have_content(number_to_currency(0))
      end
      click_on 'Lincoln, Abraham'
      expect(current_path).to eq(person_path(@creditor))
      within "div.pdfs" do
        expect(page).to have_content("Kündigungs-Schreiben")
        expect(page).to have_content("Kreditvertrag #{credit_agreement_old.number}")
        expect(page).to have_content("Kündigungs-Schreiben")
        expect(page).to have_content("Kreditvertrag #{@credit_agreement.number}")
      end
    end
  end
end


