require 'rails_helper'

RSpec.describe "Creditors index" do

  ['person', 'organization'].each do |type|
    it "shows all #{type.pluralize}" do
      @address = create type.to_sym
      visit '/creditors'
      expect(page).to have_selector("tr##{type}_#{@address.id}")
    end

    it "is possible to show all #{type.pluralize}" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "show_#{@address.id}"
      expect(current_path).to eq(send("#{type}_path", @address))
      click_on 'back'
      expect(current_path).to eq(creditors_path)
    end
  
    it "is possible to edit all #{type.pluralize}" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "edit_#{@address.id}"
      expect(current_path).to eq(send("edit_#{type}_path", @address))
      click_on 'submit'
      expect(current_path).to eq(creditors_path)
      expect(page).to have_selector('div.alert-success')
    end

    it "editing from show page leads back to show page" do
      @address = create type.to_sym
      visit send("#{type}_path", @address)
      click_on 'edit'
      click_on 'submit'
      expect(current_path).to eq(send("#{type}_path", @address))
    end

    it "is possible to cancel editing #{type.pluralize}" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "edit_#{@address.id}"
      click_on 'cancel'
      expect(current_path).to eq(creditors_path)
    end

    it "cancel while editing from show page leads back to show page" do
      @address = create type.to_sym
      visit send("#{type}_path", @address)
      click_on 'edit'
      click_on 'cancel'
      expect(current_path).to eq(send("#{type}_path", @address))
    end

    it "is possible to delete #{type.pluralize}" do
      @address = create type.to_sym
      visit creditors_path
      click_on "delete_#{@address.id}"
      expect(current_path).to eq(creditors_path)
      expect(page).not_to have_selector("tr##{type}_#{@address.id}")
      expect(page).to have_selector('div.alert-success')
    end

    it "is possible to create a #{type}" do
      visit creditors_path
      click_on "add_#{type}"
      expect(current_path).to eq(send("new_#{type}_path"))
      fill_in "#{type}_first_name", with: 'First Name' if type == 'person'
      fill_in "#{type}_name", with: 'Name'
      fill_in "#{type}_street_number", with: 'Street Number'
      fill_in "#{type}_zip", with: 'Zip'
      fill_in "#{type}_city", with: 'City'
      select 'Deutschland', from: "#{type}_country_code"
      click_on 'submit'
      expect(current_path).to match(/\/#{type.pluralize}\/\d+/)
      expect(page).to have_selector('div.alert-success')
    end
  end
end
