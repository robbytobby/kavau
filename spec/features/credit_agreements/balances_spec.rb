require 'rails_helper'

RSpec.describe "balances" do
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper
  [:admin, :accountant].each do |type|
    before :each do
      login_as create(type)
      @credit_agreement = create :credit_agreement, amount: 20000
    end

    it "is shown for each year on the credit_agreement page" do
      @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 20000, date: Date.today - 1.year
      visit credit_agreement_path(@credit_agreement)
      @balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: (Date.today - 1.year).end_of_year)
      @new_balance = @credit_agreement.balances.build
      expect(page).to have_content('Kontobewegungen')
      within("tr#deposit_#{@deposit.id}") do
        expect(page).to have_content(l(@deposit.date))
        expect(page).to have_content('Einzahlung')
        expect(page).to have_content(number_to_currency(@deposit.amount))
      end

      within("tr#balance_#{@balance.id}") do
        expect(page).to have_content(l(@balance.date))
        expect(page).to have_content('Saldo')
        expect(page).to have_content(number_to_currency(@balance.end_amount))
      end
      within('tr#balance_new') do
        expect(page).to have_content(l(Date.today))
        expect(page).to have_content('Saldo')
        expect(page).to have_content(number_to_currency(@new_balance.end_amount))
      end
    end

    context "manually edited credit agreements" do
      it "is manually editable" do
        @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 20000, date: Date.today - 1.year
        visit credit_agreement_path(@credit_agreement)
        @balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: (Date.today - 1.year).end_of_year)
        click_on "edit_balance_#{@balance.id}"
        fill_in "balance_end_amount", with: 9999
        click_on :submit
        expect(current_path).to eq(credit_agreement_path(@credit_agreement))
        within("tr#balance_#{@balance.id}.manual") do
          expect(page).to have_content(number_to_currency(9999))
        end
      end
    end

    it "I can delete manually created balances" do
      @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 20000, date: Date.today - 1.year
      @balance = create :balance, credit_agreement: @credit_agreement, end_amount: 21111, date: Date.today.prev_year.end_of_year, manually_edited: true
      visit credit_agreement_path(@credit_agreement)
      click_on "delete_balance_#{@balance.id}"
      @new_balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: (Date.today - 1.year).end_of_year)
      within("tr#balance_#{@new_balance.id}") do
        expect(page).not_to have_content(number_to_currency(9999))
      end
    end
  end
end
