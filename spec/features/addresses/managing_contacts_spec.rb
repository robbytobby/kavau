require 'rails_helper'

['Organization', 'ProjectAddress'].each do |type|
  RSpec.describe "managing contacts for #{type.underscore.pluralize}" do
    context "as non priviledged user" do
      before(:each){ @address = create type.underscore.to_sym }
      before(:each){ login_as create(:user) }

      it "I can't even show the #{type}" do
        visit model_path(@address)
        expect(current_path).to eq(root_path)
      end
    end

    [:admin, :accountant].each do |role|
      context "as #{role}" do
        before(:each){ @address = create type.underscore.to_sym }
        before(:each){ login_as create(role) }

        it "I can add a contact to a #{type.underscore}" do
          visit model_path(@address)
          click_on 'add_contact'
          expect(current_path).to eq(send("new_#{type.underscore}_contact_path", @address))
          fill_in :contact_first_name, with: 'First Name'
          fill_in :contact_name, with: 'Name'
          click_on :submit
          expect(current_path).to eq(model_path(@address))
          expect(page).to have_selector('div.alert-success')
        end

        it "I can cancel adding a contact to a #{type.underscore}" do
          visit model_path(@address)
          click_on 'add_contact'
          click_on :cancel
          expect(current_path).to eq(model_path(@address))
        end

        describe "existing contacts" do
          before(:each){ @contact = create :contact, institution: @address }

          it "I can edit a contact of a #{type.underscore}" do
            visit model_path(@address)
            click_on "edit_contact_#{@contact.id}"
            fill_in :contact_name, with: 'New Name'
            click_on :submit
            expect(current_path).to eq(model_path(@address))
            expect(page).to have_selector('div.alert-success')
          end

          it "I can cancel editing a contact of a #{type.underscore}" do
            visit model_path(@address)
            click_on "edit_contact_#{@contact.id}"
            click_on :cancel
            expect(current_path).to eq(model_path(@address))
          end
          
          it "I can delete a contact of a #{type.underscore}" do
            visit model_path(@address)
            click_on "delete_contact_#{@contact.id}"
            expect(current_path).to eq(model_path(@address))
            expect(page).to have_selector('div.alert-success')
          end
        end
      end
    end
  end

  def model_path(address)
    send("#{address.type.underscore}_path", address)
  end
end

