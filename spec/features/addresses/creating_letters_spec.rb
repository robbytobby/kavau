require 'rails_helper'

RSpec.describe "creating letters for creditors"  do
  include ActionView::Helpers::NumberHelper
  before(:each){ login_as create(:accountant) }

  before :all do
    create :balance_letter, year: 2013
    create :balance_letter, year: 2014
    create :balance_letter, year: 2015
    create :standard_letter, subject: 'Jubelbrief'
    create :standard_letter, subject: 'Trauerbrief'
    create :termination_letter
    @creditor = create :person
    @project_address = create :complete_project_address, legal_form: 'registered_society'
    @credit_agreement = create :credit_agreement, creditor: @creditor, account: @project_address.default_account
  end

  after :all do
    Letter.delete_all
    Address.delete_all
    CreditAgreement.delete_all
  end

  it "is possible" do
    visit person_path(@creditor)
    click_on :add_pdf
    expect(current_path).to eq("/people/#{@creditor.id}/pdfs/new")
    expect(page).to have_content('Trauerbrief')
    expect(page).to have_content('Jubelbrief')
    expect(page).not_to have_content('Jahresbilanz')
    expect(page).not_to have_content('Kündigungs-Schreiben')
    choose 'Jubelbrief'
    click_on :submit
    expect(current_path).to eq("/people/#{@creditor.id}")
    within 'div.pdfs' do
      expect(page).to have_content('Jubelbrief')
    end
    click_on :add_pdf
    expect(page).not_to have_content('Jubelbrief')
  end

  it "is possible for yearly balances if a deposit prior to the date exists" do
    create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: Date.new(2014, 3, 5)
    visit "/people/#{@creditor.id}/pdfs/new"
    expect(page).not_to have_content('Jahresbilanz 2013')
    expect(page).to have_content('Jahresbilanz 2014')
    expect(page).to have_content('Jahresbilanz 2015')
    choose 'Jahresbilanz 2014'
    click_on :submit
    within 'div.pdfs' do
      expect(page).to have_content('Jahresbilanz 2014')
    end
    click_on :add_pdf
    expect(page).not_to have_content('Jahresbilanz 2013')
    expect(page).not_to have_content('Jahresbilanz 2014')
    expect(page).to have_content('Jahresbilanz 2015')
  end
end

