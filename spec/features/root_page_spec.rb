require 'rails_helper'

RSpec.describe "On the home page" do
  include ActionView::Helpers::NumberHelper

  context "as unpriviledged user" do
    before(:each){ login_as create(:user) }

    it "displays the Project addresses" do
      visit "/"
      expect(page).to have_selector('h1', text: 'Addressen')
    end

    it "is not possible to add a new project address" do
      visit "/"
      expect(page).to_not have_css('a#new_project_address')
    end

    it "is not possible to show a project address" do
      @address = create :project_address
      visit "/"
      expect(page).to_not have_css("a#show_#{@address.id}")
    end

    it "is not possible to edit a project address" do
      @address = create :project_address
      visit "/"
      expect(page).to_not have_css("a#edit_#{@address.id}")
    end

    it "is not possible to delete a project address" do
      @address = create :project_address
      visit "/"
      expect(page).to_not have_css("a#delete_#{@address.id}")
    end
  end

  [:user, :accountant].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(type) }

      it "I see the Projects bank accounts" do
        @account = create :project_account
        visit "/"
        expect(page).to have_selector('h1', text: 'Konten')
        expect(page).to have_content(@account.name)
      end

      context "I can see credit_agreements summary" do
        before :each do
          @account = create :project_account
          @credit_1 = create :credit_agreement, account: @account, amount: 1000, interest_rate: '1'
          create :deposit, credit_agreement: @credit_1, amount: 1234, date: Date.today - 30.days
          create :disburse, credit_agreement: @credit_1, amount: 543, date: Date.today - 10.days
          @credit_2 = create :credit_agreement, account: @account, amount: 2000, interest_rate: '2'
          create :deposit, credit_agreement: @credit_2, amount: 1111, date: Date.today - 7.days
          create :disburse, credit_agreement: @credit_2, amount: 555, date: Date.today - 2.days
          @credit_3 = create :credit_agreement, amount: 4000, interest_rate: '3'
          create :deposit, credit_agreement: @credit_3, amount: 4000, date: Date.today - 11.days
          create :disburse, credit_agreement: @credit_3, amount: 678, date: Date.today - 3.days
        end

        it "with the sum of credits for each account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_currency(3000))
          end
        end

        it "with the sum of deposits for each account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_currency(2345))
          end
        end

        it "with the saldo for each account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_currency(@account.credit_agreements.to_a.sum(&:todays_total)))
          end
        end

        it "with the sum of disburses for each account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_currency(1098))
          end
        end

        it "with the average rate of interest for an account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_percentage(1.67))
          end
        end

        it "with the sum of all credits" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_currency(7000))
          end
        end

        it "with the average rate of interest over all accounts" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_percentage(2.43))
          end
        end

        it "with the total of deposits" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_currency(6345))
          end
        end

        it "with the total of disburses" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_currency(1776))
          end
        end

        it "with the total balance" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_currency(CreditAgreement.all.to_a.sum(&:todays_total)))
          end
        end
      end
    end
  end

  context "as accountant" do
    before(:each){ login_as create(:accountant) }

    context "# Project Addresses #" do
      it "displays the Project addresses" do
        visit "/"
        expect(page).to have_selector('h1', text: 'Addressen')
      end

      it "I can create a new project address" do
        visit "/"
        click_on 'new_project_address'
        expect(current_path).to eq(new_project_address_path)
        fill_in('project_address_name', with: 'Test Name')
        fill_in('project_address_street_number', with: 'Test Street')
        fill_in('project_address_zip', with: 'Test Zip')
        fill_in('project_address_city', with: 'Test City')
        select('Deutschland', from: 'project_address_country_code')
        click_on 'Addresse erstellen'
        # redirect to the new address
        expect(current_path).to eq(project_address_path(Address.first))
        expect(page).to have_selector('div.alert-success')
        # go back to index
        click_on('zurück')
        within('tr.project_address') do 
          find("td", text: 'Test Name')
        end
      end

      it "I can hit a link to show a project address" do
        @address = create :project_address
        visit "/"
        expect(page).to have_css("a#show_#{@address.id}")
        find_link('anzeigen', href: project_address_path(@address)).click
        expect(current_path).to eq(project_address_path(@address))
      end

      it "I can edit a project address" do
        @address = create :project_address
        visit "/project"
        find_link('bearbeiten', href: edit_project_address_path(@address)).click
        expect(current_path).to eq(edit_project_address_path(@address))
        fill_in('project_address_name', with: 'New Name')
        click_on 'Addresse aktualisieren'
        # redirects back to project#index if thats where you came from
        expect(current_path).to eq(project_path)
        expect(page).to have_selector('td', text: 'New Name')
        expect(page).to have_selector('div.alert-success')
        # redirects back to the Address if thats where you came from
        find_link('anzeigen', href: project_address_path(@address)).click
        click_on 'bearbeiten'
        click_on 'Addresse aktualisieren'
        expect(current_path).to eq(project_address_path(@address))
      end

      it "I can cancel editing an address" do
        @address = create :project_address
        visit "/project"
        find_link('bearbeiten', href: edit_project_address_path(@address)).click
        click_on 'abbrechen'
        # redirects back to project#index if thats where you came from
        expect(current_path).to eq(project_path)
        # redirects back to the Address if thats where you came from
        find_link('anzeigen', href: project_address_path(@address)).click
        click_on('bearbeiten')
        click_on 'abbrechen'
        expect(current_path).to eq(project_address_path(@address))
      end

      it "I can delete a project address" do
        @address = create :project_address, name: 'THING'
        visit "/"
        expect(page).to have_selector('td', text: 'THING')
        find_link('löschen', href: project_address_path(@address)).click
        expect(current_path).to eq(project_path)
        expect(page).not_to have_selector('td', text: 'THING')
        expect(page).to have_selector('div.alert-success')
      end
    end

  end
end

