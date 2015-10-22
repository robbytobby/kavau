require 'rails_helper'

['Organization', 'Person', 'ProjectAddress'].each do |type|
  RSpec.describe "adding contacts to #{type.underscore.pluralize}" do
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

        it "is possible to add an account to a #{type.underscore}" do
          visit model_path(@address)
          click_on 'add_account'
          expect(current_path).to eq(send("new_#{type.underscore}_account_path", @address))
          fill_in :account_bic, with: 'Bic'
          fill_in :account_iban, with: 'Iban'
          fill_in :account_bank, with: 'Bank'
          fill_in :account_name, with: 'Name'
          fill_in :account_owner, with: 'Owner'
          click_on :submit
          expect(current_path).to eq(model_path(@address))
          expect(page).to have_selector('div.alert-success')
        end

        it "is possible to cancel adding an account to a #{type.underscore}" do
          visit model_path(@address)
          click_on 'add_account'
          click_on :cancel
          expect(current_path).to eq(model_path(@address))
        end

        describe "existing accounts" do
          before(:each){ @account = create :account, address: @address }

          it "is possible to edit an account of a #{type.underscore}" do
            visit model_path(@address)
            click_on "edit_account_#{@account.id}"
            fill_in :account_name, with: 'New Name'
            click_on :submit
            expect(current_path).to eq(model_path(@address))
            expect(page).to have_selector('div.alert-success')
          end

          it "is possible to cancel editing an account of a #{type.underscore}" do
            visit model_path(@address)
            click_on "edit_account_#{@account.id}"
            click_on :cancel
            expect(current_path).to eq(model_path(@address))
          end
          
          it "is possible to delete an account of a #{type.underscore}" do
            visit model_path(@address)
            click_on "delete_account_#{@account.id}"
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
