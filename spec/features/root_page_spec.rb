require 'rails_helper'

RSpec.describe "Home page" do
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

  context "as accountant" do
    before(:each){ login_as create(:accountant) }

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

