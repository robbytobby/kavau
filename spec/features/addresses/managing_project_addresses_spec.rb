require 'rails_helper'

RSpec.describe "Managing project_addresses"  do
  [:admin, :accountant].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(type) }

      it "I can create a project address" do
        visit '/'
        click_on :new_project_address
        expect(current_path).to eq(new_project_address_path)
        fill_in :project_address_name, with: 'Name'
        select 'e.V.', from: :project_address_legal_form
        fill_in :project_address_street_number, with: 'StreetNumber'
        fill_in :project_address_zip, with: 'Zip'
        fill_in :project_address_city, with: 'City'
        select 'Deutschland', from: :project_address_country_code, match: :first
        click_on :submit
        expect(current_path).to eq(project_address_path(ProjectAddress.last))
        expect(page).to have_selector('div.alert-notice')
      end

      it "I can cancel creating a project address" do
        visit '/'
        click_on :new_project_address
        click_on :cancel
        expect(current_path).to eq('/project')
      end

      describe "existing project addresses" do
        before(:each){ @project_address = create :project_address }

        it "I can edit a project_address" do
          visit '/'
          click_on "edit_project_address_#{@project_address.id}"
          fill_in :project_address_name, with: 'New Name'
          click_on :submit
          expect(current_path).to eq('/project')
          expect(page).to have_selector('div.alert-notice')
        end

        it "I can cancel editing a project address" do
          visit '/'
          click_on "edit_project_address_#{@project_address.id}"
          click_on :cancel
          expect(current_path).to eq('/project')
        end

        it "I can delete a project_address" do
          visit '/'
          click_on "delete_project_address_#{@project_address.id}"
          expect(current_path).to eq('/project')
          expect(page).to have_selector('div.alert-notice')
        end
      end
    end
  end
end
