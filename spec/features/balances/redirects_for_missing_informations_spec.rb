require 'rails_helper'
RSpec.describe "balances pdfs for project address with missing information" do
  before :each do
    login_as create :accountant
  end

  context "template for covering letter exists" do
    before :each do
      create :balance_letter, year: Date.today.prev_year.year
    end

    it "no contacts given" do
      @project_address = create :project_address, :with_legals, :with_default_account
      account = create :account, address: @project_address
      credit_agreement = create :credit_agreement, account: account
      create :deposit, credit_agreement: credit_agreement, date: Date.today - 1.year
      @balance = credit_agreement.balances.last
      visit "/balances/#{@balance.id}.pdf"
      expect(current_path).to eq(project_address_path(@project_address))
      within '#flash_warning' do
        expect(page).to have_content('Geschäftsführer')
      end
    end

    it "no legal_information given" do
      @project_address = create :project_address, :with_contacts, :with_default_account
      account = create :account, address: @project_address
      credit_agreement = create :credit_agreement, account: account
      create :deposit, credit_agreement: credit_agreement, date: Date.today - 1.year
      @balance = credit_agreement.balances.last
      visit "/balances/#{@balance.id}.pdf"
      expect(current_path).to eq(project_address_path(@project_address))
      within '#flash_warning' do
        expect(page).to have_content('Sitz, Registergericht, Register-Nr und UST-Id-Nr oder Steuernummer')
      end
    end

    it "no legal_information given" do
      @project_address = create :project_address, :with_contacts, :with_legals
      account = create :account, address: @project_address
      credit_agreement = create :credit_agreement, account: account
      create :deposit, credit_agreement: credit_agreement, date: Date.today - 1.year
      @balance = credit_agreement.balances.last
      visit "/balances/#{@balance.id}.pdf"
      expect(current_path).to eq(project_address_path(@project_address))
      within '#flash_warning' do
        expect(page).to have_content('Standard-Konto')
      end
    end
  end
end

