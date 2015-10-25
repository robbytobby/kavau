require 'rails_helper'

RSpec.describe "creditors index view" do
  context "as an unpriviledged user" do
    before(:each){ login_as create(:user) }

    it "is not possible do acces the creditors index" do
      visit '/creditors'
      expect(current_path).to eq('/')
    end
  end

  context "as an accountant" do
    before(:each){ login_as create(:accountant) }

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
        click_on "edit_#{type}_#{@address.id}"
        expect(current_path).to eq(send("edit_#{type}_path", @address))
      end

      it "is possible to create a #{type}" do
        visit creditors_path
        click_on "add_#{type}"
        expect(current_path).to eq(send("new_#{type}_path"))
      end

      it "shows notes in a popover" do
        @address = create type.to_sym, notes: 'NOTES'
        visit '/creditors'
        expect(page).to have_css("span[data-content='NOTES']")
      end
    end
  end
end
