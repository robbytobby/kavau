require 'rails_helper'

RSpec.describe "conditional redirects for creditors in address_controller" do
  before(:each){ login_as create(:user) }

  ['person', 'organization'].each do |type|
    it "coming form index, then successfully editing a #{type.pluralize} leads back to index" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "edit_#{@address.id}"
      click_on 'submit'
      expect(current_path).to eq(creditors_path)
      expect(page).to have_selector('div.alert-success')
    end

    it "coming from show, then successfully editing a #{type.pluralize} leads back to show" do
      @address = create type.to_sym
      visit send("#{type}_path", @address)
      click_on 'edit'
      click_on 'submit'
      expect(current_path).to eq(send("#{type}_path", @address))
    end

    it "cancel editing when coming from index leads back to index" do
      @address = create type.to_sym
      visit '/creditors'
      click_on "edit_#{@address.id}"
      click_on 'cancel'
      expect(current_path).to eq(creditors_path)
    end

    it "cancel editing when from show page leads back to show page" do
      @address = create type.to_sym
      visit send("#{type}_path", @address)
      click_on 'edit'
      click_on 'cancel'
      expect(current_path).to eq(send("#{type}_path", @address))
    end

    it "deleting a #{type} leads back to index" do
      @address = create type.to_sym
      visit creditors_path
      click_on "delete_#{@address.id}"
      expect(current_path).to eq(creditors_path)
      expect(page).not_to have_selector("tr##{type}_#{@address.id}")
      expect(page).to have_selector('div.alert-success')
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
      expect(page).to have_selector('div.alert-success')
    end
  end
end
