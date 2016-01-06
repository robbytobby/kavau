require 'rails_helper'

RSpec.describe "balances" do
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper
  [:admin, :accountant].each do |type|
    context "- as #{type} -" do
      before :each do
        login_as create(type)
        @credit_agreement = create :credit_agreement, amount: 20000
      end

      context "on the credit agreement show page" do
        it "are shown on the credit_agreement page" do
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 20000, date: Date.today - 1.year
          visit credit_agreement_path(@credit_agreement)
          @balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: (Date.today - 1.year).end_of_year)
          @new_balance = @credit_agreement.auto_balances.build
          expect(page).to have_content('Kontobewegungen')
          within("tr#deposit_#{@deposit.id}") do
            expect(page).to have_content(l(@deposit.date))
            expect(page).to have_content('Einzahlung')
            expect(page).to have_content(number_to_currency(@deposit.amount))
          end

          within("tr#auto_balance_#{@balance.id}") do
            expect(page).to have_content(l(@balance.date))
            expect(page).to have_content('Saldo')
            expect(page).to have_content(number_to_currency(@balance.end_amount))
          end
          within('tr#auto_balance_new') do
            expect(page).to have_content(l(Date.today))
            expect(page).to have_content('Saldo')
            expect(page).to have_content(number_to_currency(@new_balance.end_amount))
          end
        end

        it "I can edit them" do
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 20000, date: Date.today - 1.year
          visit credit_agreement_path(@credit_agreement)
          @balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: (Date.today - 1.year).end_of_year)
          click_on "edit_auto_balance_#{@balance.id}"
          fill_in "auto_balance_end_amount", with: 20100
          click_on :submit
          expect(current_path).to eq(credit_agreement_path(@credit_agreement))
          within("tr#manual_balance_#{@balance.id}") do
            expect(page).to have_content(number_to_currency(20100))
          end
          within("tr.interest.manual") do
            expect(page).to have_content(number_to_currency(100))
            expect(page).to have_content('manuell berechnet')
          end
        end

        it "I can delete manually created balances" do
          @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 20000, date: Date.today - 1.year
          @balance = create :manual_balance, credit_agreement: @credit_agreement, end_amount: 21111, date: Date.today.prev_year.end_of_year
          visit credit_agreement_path(@credit_agreement)
          click_on "delete_manual_balance_#{@balance.id}"
          @new_balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: (Date.today - 1.year).end_of_year)
          within("tr#auto_balance_#{@new_balance.id}") do
            expect(page).not_to have_content(number_to_currency(9999))
          end
        end
      end

      context "on the index page" do
        before :each do
          @credit_agreements = create_list :credit_agreement, 3
          @credit_agreements.each{|c| create :deposit, credit_agreement: c, date: Date.today.prev_year, amount: 5000}
          @credit_agreements.each{|c| create :disburse, credit_agreement: c, date: Date.today.prev_year, amount: 2000}
          @balances = @credit_agreements.map{|c| create :balance, credit_agreement: c, date: Date.today.beginning_of_year.prev_day }
          @manual_balance = create :manual_balance
        end

        it "all balances are shown" do
          visit balances_path
          @balances.each do |bal|
            expect(page).to have_css("tr#auto_balance_#{bal.id}")
            within "tr#auto_balance_#{bal.id}" do
              expect(page).to have_content bal.credit_agreement.number
              expect(page).to have_content I18n.l(bal.date)
              expect(page).to have_content bal.creditor.name
              expect(page).to have_content number_to_currency(bal.start_amount)
              expect(page).to have_content number_to_currency(5000)
              expect(page).to have_content number_to_currency(2000)
              expect(page).to have_content number_to_currency(bal.interests_sum)
              expect(page).to have_content number_to_currency(bal.end_amount)
              expect(page).to have_css("a#edit_auto_balance_#{bal.id}")
              expect(page).not_to have_css("a#delete_balance_#{bal.id}")
            end
          end
          within "tr#manual_balance_#{@manual_balance.id}" do
            expect(page).to have_css("a#delete_manual_balance_#{@manual_balance.id}")
          end
        end
      end
    end
  end
end
