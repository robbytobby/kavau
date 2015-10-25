require 'rails_helper'

RSpec.describe "Managing project_addresses"  do
  before(:each){ login_as create(:admin) }

  it "creating a new one is possible" do
    visit '/'
    click_on :new_project_address
    expect(current_path).to eq(new_project_address_path)
    fill_in :project_address_name, with: 'Name'
    fill_in :project_address_street_number, with: 'StreetNumber'
    fill_in :project_address_zip, with: 'Zip'
    fill_in :project_address_city, with: 'City'
    select 'Deutschland', from: :project_address_country_code
    click_on :submit
    expect(current_path).to eq(project_address_path(ProjectAddress.last))
    expect(page).to have_selector('div.alert-success')
  end

  it "canceling creating a new project address is possible" do
    visit '/'
    click_on :new_project_address
    click_on :cancel
    expect(current_path).to eq('/project')
  end

  describe "existing project addresses" do
    before(:each){ @project_address = create :project_address }

    it "is possible to edit a project_address" do
      visit '/'
      click_on "edit_project_address_#{@project_address.id}"
      fill_in :project_address_name, with: 'New Name'
      click_on :submit
      expect(current_path).to eq('/project')
      expect(page).to have_selector('div.alert-success')
    end

    it "is possible to cancel editing" do
      visit '/'
      click_on "edit_project_address_#{@project_address.id}"
      click_on :cancel
      expect(current_path).to eq('/project')
    end

    it "is possible to delete a project_address" do
      visit '/'
      click_on "delete_project_address_#{@project_address.id}"
      expect(current_path).to eq('/project')
      expect(page).to have_selector('div.alert-success')
    end
  end
end
