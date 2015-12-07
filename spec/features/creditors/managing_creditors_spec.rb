require 'rails_helper'

RSpec.describe "Managing creditors"  do
  before(:each){ login_as create(:accountant) }

  [:person, :organization].each do |type|
    it "creating a #{type} is possible" do
      visit creditors_path
      click_on "add_#{type}"
      expect(current_path).to eq(send("new_#{type}_path"))
      select 'Herr', from: "#{type}_salutation" if type == :person
      select 'GmbH', from: "#{type}_legal_form" if type == :organization
      fill_in "#{type}_name", with: 'Name'
      fill_in "#{type}_first_name", with: 'Name' if type == :person
      fill_in "#{type}_street_number", with: 'Street Number'
      fill_in "#{type}_zip", with: 'Zip'
      fill_in "#{type}_city", with: 'City'
      select "Deutschland", from: "#{type}_country_code", match: :first
      click_on :submit
      expect(current_path).to eq(send("#{type}_path", Address.last))
      expect(page).to have_selector('div.alert-notice')
    end

    it "canceling creating a #{type} is possible" do
      visit creditors_path
      click_on "add_#{type}"
      click_on :cancel
      expect(current_path).to eq(creditors_path)
    end

    context "existing #{type}" do
      before(:each){@creditor = create type}

      it "is editable" do
        visit creditors_path
        click_on "edit_#{type}_#{@creditor.id}"
        fill_in "#{type}_name", with: 'New Name'
        click_on :submit
        expect(current_path).to eq(creditors_path)
        expect(page).to have_selector('div.alert-notice')
      end

      it "canceling editing possible" do
        visit creditors_path
        click_on "edit_#{type}_#{@creditor.id}"
        click_on :cancel
        expect(current_path).to eq(creditors_path)
      end

      it "is deletable" do
        visit creditors_path
        click_on "delete_#{type}_#{@creditor.id}"
        expect(current_path).to eq(creditors_path)
        expect(page).to have_selector('div.alert-notice')
      end
    end
  end
end

