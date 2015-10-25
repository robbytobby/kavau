require 'rails_helper'

RSpec.describe "Managing creditors"  do
  before(:each){ login_as create(:accountant) }

  [:person, :organization].each do |type|
    it "creating is possible" do
      visit creditors_path
      click_on "add_#{type}"
      expect(current_path).to eq(send("new_#{type}_path"))
      fill_in "#{type}_name", with: 'Name'
      fill_in "#{type}_first_name", with: 'Name' if type == :person
      fill_in "#{type}_street_number", with: 'Street Number'
      fill_in "#{type}_zip", with: 'Zip'
      fill_in "#{type}_city", with: 'City'
      select "Deutschland", from: "#{type}_country_code"
      click_on :submit
      expect(current_path).to eq(send("#{type}_path", Address.last))
      expect(page).to have_selector('div.alert-success')
    end

    it "canceling create is possible" do
      visit creditors_path
      click_on "add_#{type}"
      click_on :cancel
      expect(current_path).to eq(creditors_path)
    end

    context "existing #{type}" do
      before(:each){@creditor = create type}

      it "is possible to edit" do
        visit creditors_path
        click_on "edit_#{type}_#{@creditor.id}"
        fill_in "#{type}_name", with: 'New Name'
        click_on :submit
        expect(current_path).to eq(creditors_path)
        expect(page).to have_selector('div.alert-success')
      end

      it "is possible to cancel editing" do
        visit creditors_path
        click_on "edit_#{type}_#{@creditor.id}"
        click_on :cancel
        expect(current_path).to eq(creditors_path)
      end

      it "is possible to delete" do
        visit creditors_path
        click_on "delete_#{type}_#{@creditor.id}"
        expect(current_path).to eq(creditors_path)
        expect(page).to have_selector('div.alert-success')
      end
    end
  end
end

