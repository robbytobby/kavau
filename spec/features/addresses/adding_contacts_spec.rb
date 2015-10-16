require 'rails_helper'

['Organization', 'ProjectAddress'].each do |type|
  RSpec.describe "adding contacts to #{type.underscore.pluralize}" do
    before(:each){ @address = create type.underscore.to_sym }

    it "is possible to add a contact to a #{type.underscore}" do
      visit model_path(@address)
      click_on 'add_contact'
      expect(current_path).to eq(send("new_#{type.underscore}_contact_path", @address))
      fill_in :contact_first_name, with: 'First Name'
      fill_in :contact_name, with: 'Name'
      click_on :submit
      expect(current_path).to eq(model_path(@address))
      expect(page).to have_selector('div.alert-success')
    end

    it "is possible to cancel adding a contact to a #{type.underscore}" do
      visit model_path(@address)
      click_on 'add_contact'
      click_on :cancel
      expect(current_path).to eq(model_path(@address))
    end

    describe "existing contacts" do
      before(:each){ @contact = create :contact, organization: @address }

      it "is possible to edit a contact of a #{type.underscore}" do
        visit model_path(@address)
        click_on "edit_#{@contact.id}"
        fill_in :contact_name, with: 'New Name'
        click_on :submit
        expect(current_path).to eq(model_path(@address))
        expect(page).to have_selector('div.alert-success')
      end

      it "is possible to cancel editing a contact of a #{type.underscore}" do
        visit model_path(@address)
        click_on "edit_#{@contact.id}"
        click_on :cancel
        expect(current_path).to eq(model_path(@address))
      end
      
      it "is possible to delete a contact of a #{type.underscore}" do
        visit model_path(@address)
        click_on "delete_#{@contact.id}"
        expect(current_path).to eq(model_path(@address))
        expect(page).to have_selector('div.alert-success')
      end
    end
  end

  def model_path(address)
    send("#{address.type.underscore}_path", address)
  end
end

