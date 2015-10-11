require 'rails_helper'

RSpec.describe "Home page" do
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
    expect(current_path).to eq(project_path)
    within('tr.project_address') do 
      find("td", text: 'Test Name')
    end
    expect(page).to have_selector('div.alert-success')
  end

  it "is possible to show a project address" do
    @address = create :project_address
    visit "/"
    find_link('anzeigen', href: project_address_path(@address)).click
    expect(current_path).to eq(project_address_path(@address))
  end

  it "is possibel to edit a project address" do
    @address = create :project_address
    visit "/"
    find_link('bearbeiten', href: edit_project_address_path(@address)).click
    expect(current_path).to eq(edit_project_address_path(@address))
    fill_in('project_address_name', with: 'New Name')
    click_on 'Addresse aktualisieren'
    expect(current_path).to eq(project_path)
    expect(page).to have_selector('td', text: 'New Name')
    expect(page).to have_selector('div.alert-success')
  end

  it "is possible to cancel editing an address" do
    @address = create :project_address
    visit edit_project_address_path(@address)
    click_on 'abbrechen'
    expect(current_path).to eq(project_path)
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

