require 'rails_helper'

RSpec.describe "managing credit agreements" do
  include ActionView::Helpers::NumberHelper
  before(:each){ 
    allow_any_instance_of(Deposit).to receive(:not_before_credit_agreement_starts).and_return(true) 
  }

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      before :each do
        @current_user = create type
        login_as @current_user
        @credit = create :credit_agreement
      end

      it "I can go to the credit agreement from credit agreements index" do
        visit '/credit_agreements'
        click_on "show_credit_agreement_#{@credit.id}", match: :first
        expect(current_path).to eq(credit_agreement_path(@credit))
      end

      it "I can go to the credit agreement from creditors page" do
        visit model_path(@credit.creditor)
        click_on "show_credit_agreement_#{@credit.id}", match: :first
        expect(current_path).to eq(credit_agreement_path(@credit))
      end

      it "the credit agreement page show the basic data" do
        visit credit_agreement_path(@credit)
        expect(page).to have_content(@credit.number)
        expect(page).to have_content(@credit.account.name)
        expect(page).to have_content(@credit.creditor.name)
        expect(page).to have_content(number_to_currency(@credit.amount))
        expect(page).to have_content(number_to_percentage(@credit.interest_rate))
        expect(page).to have_content(@credit.cancellation_period)
      end

      it "has a history" do
        with_versioning do
          @credit_agreement = create :credit_agreement, valid_from: Date.new(2015, 2, 1), amount: 1000, interest_rate: 0
          dont_validate_fund_for @credit_agreement
          @credit_agreement.update_attributes!(amount: 2000, valid_from: Date.new(2015, 3, 2))
          @credit_agreement.update_attributes!(interest_rate: 1, valid_from: Date.new(2015, 3, 2))
          @credit_agreement.update_attributes!(interest_rate: 2, valid_from: Date.new(2015, 12, 2))
        end
        visit credit_agreement_path(@credit_agreement)
        expect(page).to have_selector('div#history.collapse')
        within '#history' do
          within "div#credit_agreement_version_#{@credit_agreement.versions[0].id}" do
            expect(page).to have_content(I18n.l(Date.today))
            expect(page).to have_content("angelegt von Unbekannter User")
            expect(page).to have_content('Betrag: 1.000,00 €')
            expect(page).to have_content('Kündigungsfrist: 3 Monate')
            expect(page).to have_content("Konto: #{@credit_agreement.account.name}")
            expect(page).to have_content("Nr: #{@credit_agreement.number}")
            expect(page).to have_content("Gültig ab: 01.02.2015")
          end
          within "div#credit_agreement_version_#{@credit_agreement.versions[1].id}" do
            expect(page).to have_content(I18n.l(Date.today))
            expect(page).to have_content("geändert von Unbekannter User")
            expect(page).to have_content("Betrag: 1.000,00 € → 2.000,00 €")
            expect(page).to have_content("Gültig ab: 01.02.2015 → 02.03.2015")
          end
          within "div#credit_agreement_version_#{@credit_agreement.versions[2].id}" do
            expect(page).to have_content(I18n.l(Date.today))
            expect(page).to have_content("geändert von Unbekannter User")
            expect(page).to have_content("Zinssatz: 0,00% → 1,00%")
          end
          within "div#credit_agreement_version_#{@credit_agreement.versions[3].id}" do
            expect(page).to have_content(I18n.l(Date.today))
            expect(page).to have_content("geändert von Unbekannter User")
            expect(page).to have_content("Zinssatz: 1,00% → 2,00%")
            expect(page).to have_content("Gültig ab: 02.03.2015 → 02.12.2015")
          end
        end
      end

      it "has everything in the right order" do
        @deposit_3_1 = create :deposit, credit_agreement: @credit, date: Date.today.prev_year(3).end_of_year.beginning_of_month
        @deposit_1_1 = create :deposit, credit_agreement: @credit, date: Date.today.prev_year(1).beginning_of_year.next_month(3)
        @deposit_1_2 = create :deposit, credit_agreement: @credit, date: Date.today.prev_year(1).end_of_year
        @deposit_0_1 = create :deposit, credit_agreement: @credit, date: Date.today.beginning_of_year
        @deposit_0_2 = create :deposit, credit_agreement: @credit, date: Date.today
        visit credit_agreement_path(@credit)
        within('#balances') do
          expect(page).to have_css("tr#deposit_#{@deposit_3_1.id}[nth-child(1)]")
          # Year -3
          within "tr.interest[nth-child(2)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_3_1.date), I18n.l(@deposit_3_1.date.end_of_year)].join(' - '))
            end
          end
          within "tr.auto_balance[nth-child(3)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(@deposit_3_1.date.end_of_year))
            end
          end
          # Year -2
          within "tr.interest[nth-child(4)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(Date.today.prev_year(3).end_of_year), I18n.l(Date.today.prev_year(2).end_of_year)].join(' - '))
            end
          end
          within "tr.auto_balance[nth-child(5)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(Date.today.prev_year(2).end_of_year))
            end
          end
          # Year -1
          within "tr.interest[nth-child(6)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_1_1.date.prev_year.end_of_year), I18n.l(@deposit_1_1.date)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_1_1.id}[nth-child(7)]")
          within "tr.interest[nth-child(8)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_1_1.date), I18n.l(@deposit_1_2.date)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_1_2.id}[nth-child(9)]")
          within "tr.auto_balance[nth-child(10)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(Date.today.prev_year(1).end_of_year))
            end
          end
          # Year 0
          within "tr.interest[nth-child(11)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_0_1.date.prev_year.end_of_year), I18n.l(@deposit_0_1.date)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_0_1.id}[nth-child(12)]")
          within "tr.interest[nth-child(13)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_0_1.date), I18n.l(@deposit_0_2.date)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_0_2.id}[nth-child(14)]")
          within "tr.auto_balance[nth-child(15)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(Date.today))
            end
          end
        end
      end

      it "has everything in the right order - manual balances" do
        @deposit_3_1 = create :deposit, credit_agreement: @credit, date: Date.today.prev_year(3).end_of_year.beginning_of_month
        @deposit_1_1 = create :deposit, credit_agreement: @credit, date: Date.today.prev_year(1).beginning_of_year.next_month(3)
        @deposit_1_2 = create :deposit, credit_agreement: @credit, date: Date.today.prev_year(1).end_of_year
        @deposit_0_1 = create :deposit, credit_agreement: @credit, date: Date.today.beginning_of_year
        @deposit_0_2 = create :deposit, credit_agreement: @credit, date: Date.today
        @credit.balances.each do |bal|
          bal.becomes_manual_balance.save
        end
        visit credit_agreement_path(@credit)
        within('#balances') do
          # Year -3
          within "tr.interest[nth-child(2)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_3_1.date), I18n.l(@deposit_3_1.date.end_of_year)].join(' - '))
            end
          end
          within "tr.manual_balance[nth-child(3)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(@deposit_3_1.date.end_of_year))
            end
          end
          # Year -2
          within "tr.interest[nth-child(4)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(Date.today.prev_year(3).end_of_year), I18n.l(Date.today.prev_year(2).end_of_year)].join(' - '))
            end
          end
          within "tr.manual_balance[nth-child(5)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(Date.today.prev_year(2).end_of_year))
            end
          end
          # Year -1
          expect(page).to have_css("tr#deposit_#{@deposit_1_1.id}[nth-child(6)]")
          within "tr.interest[nth-child(7)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(Date.today.prev_year(2).end_of_year), I18n.l(Date.today.prev_year(1).end_of_year)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_1_2.id}[nth-child(8)]")
          within "tr.manual_balance[nth-child(9)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(Date.today.prev_year(1).end_of_year))
            end
          end
          # Year 0
          within "tr.interest[nth-child(10)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_0_1.date.prev_year.end_of_year), I18n.l(@deposit_0_1.date)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_0_1.id}[nth-child(11)]")
          within "tr.interest[nth-child(12)]" do
            within "td[nth-child(3)]" do
              expect(page).to have_content([I18n.l(@deposit_0_1.date), I18n.l(@deposit_0_2.date)].join(' - '))
            end
          end
          expect(page).to have_css("tr#deposit_#{@deposit_0_2.id}[nth-child(13)]")
          within "tr.auto_balance[nth-child(14)]" do
            within "td[nth-child(1)]" do
              expect(page).to have_content(I18n.l(Date.today))
            end
          end
        end
      end
    end
  end

  def model_path(address)
    send("#{address.type.underscore}_path", address)
  end
end

