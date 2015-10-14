require 'rails_helper'

RSpec.describe "creditors index view" do

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
    end

    it "is possible to create a #{type}" do
      visit creditors_path
      click_on "add_#{type}"
      expect(current_path).to eq(send("new_#{type}_path"))
    end
  end
end
