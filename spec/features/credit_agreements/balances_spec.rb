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
        expect(page).to have_content(@deposit.interest.interest_days)
        expect(page).to have_content(number_to_currency(@deposit.amount))
        expect(page).to have_content(number_to_currency(@deposit.interest.amount))
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
      within('tr.interest') do
        expect(page).to have_content(l(Date.today))
        expect(page).to have_content(number_to_currency(@new_balance.start_amount))
        expect(page).to have_content(@new_balance.to_interest.interest_days)
        expect(page).to have_content(number_to_currency(@new_balance.interest_from_start_amount.amount))
      end
    end
  end
end
