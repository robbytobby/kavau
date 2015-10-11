require 'rails_helper'

RSpec.describe "Creditors index" do
  before :each do
    @person = create :person
    @organization = create :organization
  end

  it "shows all creditors - persons and organizations" do
    visit '/creditors'
    expect(page).to have_selector("tr#person_#{@person.id}")
    expect(page).to have_selector("tr#organization_#{@organization.id}")
  end

  it "is possible to show all creditor types" do
    visit '/creditors'
    within("tr#person_#{@person.id}") do
      click_on 'anzeigen'
      expect(current_path).to eq(person_path @person)
    end
    click_on 'zurück'
    expect(current_path).to eq(creditors_path)
    within("tr#organization_#{@organization.id}") do
      click_on 'anzeigen'
      expect(current_path).to eq(organization_path @organization)
    end
    click_on 'zurück'
    expect(current_path).to eq(creditors_path)
  end

  
  it "is possible to edit all creditor types" do
    visit '/creditors'
    within("tr#person_#{@person.id}") do
      click_on 'bearbeiten'
      expect(current_path).to eq(edit_person_path @person)
    end
    fill_in 'person_name', with: 'New Name'
    click_on 'Addresse aktualisieren'
    expect(current_path).to eq(person_path @person)
    expect(page).to have_selector('div.alert-success')
    click_on 'zurück'
    expect(current_path).to eq(creditors_path)
    within("tr#organization_#{@organization.id}") do
      click_on 'bearbeiten'
      expect(current_path).to eq(edit_organization_path @organization)
    end
    fill_in 'organization_name', with: 'New Name'
    click_on 'Addresse aktualisieren'
    expect(current_path).to eq(organization_path @organization)
    expect(page).to have_selector('div.alert-success')
    click_on 'zurück'
    expect(current_path).to eq(creditors_path)
  end

  it "is possible to cancel editing people and organizations" do
    visit edit_person_path(@person)
    click_on 'abbrechen'
    expect(current_path).to eq(creditors_path)
    visit edit_organization_path(@organization)
    click_on 'abbrechen'
    expect(current_path).to eq(creditors_path)
  end

  it "is possible to delete people and organizations" do
    visit creditors_path
    within("tr#person_#{@person.id}") do
      click_on 'löschen'
    end
    expect(current_path).to eq(creditors_path)
    expect(page).not_to have_selector("tr#person_#{@person.id}")
    expect(page).to have_selector('div.alert-success')
    within("tr#organization_#{@organization.id}") do
      click_on 'löschen'
    end
    expect(current_path).to eq(creditors_path)
    expect(page).not_to have_selector("tr#organization_#{@organization.id}")
    expect(page).to have_selector('div.alert-success')
  end
end
