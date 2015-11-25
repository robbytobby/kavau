require 'rails_helper'

RSpec.describe "conditional redirects for creditors in address_controller" do
  before(:each){ login_as create(:admin) }

  ['person', 'organization'].each do |type|
    it "coming from creditors index, then successfully editing a #{type} leads back to the creditors index" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "edit_#{type}_#{@address.id}"
      click_on 'submit'
      expect(current_path).to eq(creditors_path)
      expect(page).to have_selector('div.alert-notice')
    end

    it "coming from the #{type}s page, then successfully editing a #{type.pluralize} leads back to the #{type}s page" do
      @address = create type.to_sym
      visit send("#{type}_path", @address)
      click_on 'edit'
      click_on 'submit'
      expect(current_path).to eq(send("#{type}_path", @address))
    end

    it "cancel editing a #{type} when coming from creditors index leads back to index" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "edit_#{type}_#{@address.id}"
      click_on 'cancel'
      expect(current_path).to eq(creditors_path)
    end

    it "cancel editing a #{type} when coming from its show page leads back to its show page" do
      @address = create type.to_sym
      visit send("#{type}_path", @address)
      click_on 'edit'
      click_on 'cancel'
      expect(current_path).to eq(send("#{type}_path", @address))
    end

    it "deleting a #{type} leads back to creditors index" do
      @address = create type.to_sym
      visit creditors_path
      click_on "delete_#{type}_#{@address.id}"
      expect(current_path).to eq(creditors_path)
      expect(page).not_to have_selector("tr##{type}_#{@address.id}")
      expect(page).to have_selector('div.alert-notice')
    end

    it "creating a #{type} leads to the newly created record" do
      visit creditors_path
      click_on "add_#{type}"
      fill_in "#{type}_first_name", with: 'First Name' if type == 'person'
      fill_in "#{type}_name", with: 'Name'
      fill_in "#{type}_street_number", with: 'Street Number'
      fill_in "#{type}_zip", with: 'Zip'
      fill_in "#{type}_city", with: 'City'
      select 'Deutschland', from: "#{type}_country_code"
      click_on 'submit'
      expect(current_path).to match(/\/#{type.pluralize}\/\d+/)
      expect(page).to have_selector('div.alert-notice')
    end
  end
end
