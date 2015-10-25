require 'rails_helper'

RSpec.describe "Home page" do
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

    it "is not possible to show a project address" do
      @address = create :project_address
      visit "/"
      expect(page).to_not have_css("a#edit_#{@address.id}")
    end

    it "is not possible to show a project address" do
      @address = create :project_address
      visit "/"
      expect(page).to_not have_css("a#delete_#{@address.id}")
    end
  end

  [:user, :accountant].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(type) }

      it "displays the Projects bank accounts" do
        @account = create :project_account
        visit "/"
        expect(page).to have_selector('h1', text: 'Konten')
        expect(page).to have_content(@account.name)
      end

      context "credit_agreements" do
        before :each do
          @account = create :project_account
          @credit_1 = create :credit_agreement, account: @account, amount: 1000, interest_rate: '1'
          @credit_2 = create :credit_agreement, account: @account, amount: 2000, interest_rate: '2'
          @credit_3 = create :credit_agreement, amount: 4000, interest_rate: '3'
        end

        it "displays the sum of credits for each account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_currency(3000))
          end
        end

        it "displays the average rate of interest for an account" do
          visit "/"
          within("tr#account_#{@account.id}") do
            expect(page).to have_content(number_to_percentage(1.67))
          end
        end

        it "displays the sum of all credits" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_currency(7000))
          end
        end

        it "displays the average rate of interest for an account" do
          visit "/"
          within("tr.sums") do
            expect(page).to have_content(number_to_percentage(2.43))
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

      it "is possible to create a new project address" do
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

      it "is possible to show a project address" do
        @address = create :project_address
        visit "/"
        expect(page).to have_css("a#show_#{@address.id}")
        find_link('anzeigen', href: project_address_path(@address)).click
        expect(current_path).to eq(project_address_path(@address))
      end

      it "is possibel to edit a project address" do
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

      it "is possible to cancel editing an address" do
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

      it "is possible to delete a project address" do
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

