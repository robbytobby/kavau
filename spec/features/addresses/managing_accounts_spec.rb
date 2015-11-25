require 'rails_helper'
RSpec.describe "managing account for ProjectAddress" do
  [:admin, :accountant].each do |role|
    before(:each){ @address = create :project_address }
    before(:each){ login_as create(role) }

    context "as #{role}" do
      it "I can set a default account" do
        visit model_path(@address)
        click_on 'add_account'
        expect(current_path).to eq(send("new_project_address_account_path", @address))
        fill_in :account_bic, with: 'GENODEF1S02'
        fill_in :account_iban, with: 'GB82 WEST 1234 5698 7654 32'
        fill_in :account_bank, with: 'Bank'
        fill_in :account_name, with: 'DefaultAccount'
        check 'account_default'
        click_on :submit
        expect(current_path).to eq(model_path(@address))
        expect(page).to have_selector('div.alert-notice')
        expect(@address.default_account.name).to eq('DefaultAccount')
      end

      it "I can change the default account" do
        account1 = create :account, address: @address, default: true 
        account2 = create :account, address: @address, default: false
        visit model_path(@address)
        click_on "edit_account_#{account2.id}"
        check 'account_default'
        click_on :submit
        expect(@address.default_account).to eq(account2)
      end
    end
  end
end

['Organization', 'Person', 'ProjectAddress'].each do |type|
  RSpec.describe "managing accounts for #{type.underscore.pluralize}" do
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

        it "I can add an account to a #{type.underscore}" do
          visit model_path(@address)
          click_on 'add_account'
          expect(current_path).to eq(send("new_#{type.underscore}_account_path", @address))
          fill_in :account_bic, with: 'GENODEF1S02'
          fill_in :account_iban, with: 'GB82 WEST 1234 5698 7654 32'
          fill_in :account_bank, with: 'Bank'
          fill_in :account_name, with: 'Name'
          fill_in :account_owner, with: 'Owner'
          click_on :submit
          expect(current_path).to eq(model_path(@address))
          expect(page).to have_selector('div.alert-notice')
        end

        it "I can cancel adding an account to a #{type.underscore}" do
          visit model_path(@address)
          click_on 'add_account'
          click_on :cancel
          expect(current_path).to eq(model_path(@address))
        end

        describe "existing accounts" do
          before(:each){ @account = create :account, address: @address }

          it "I can edit an account of a #{type.underscore}" do
            visit model_path(@address)
            click_on "edit_account_#{@account.id}"
            fill_in :account_name, with: 'New Name'
            click_on :submit
            expect(current_path).to eq(model_path(@address))
            expect(page).to have_selector('div.alert-notice')
          end

          it "I can cancel editing an account of a #{type.underscore}" do
            visit model_path(@address)
            click_on "edit_account_#{@account.id}"
            click_on :cancel
            expect(current_path).to eq(model_path(@address))
          end
          
          it "I can delete an account of a #{type.underscore}" do
            visit model_path(@address)
            click_on "delete_account_#{@account.id}"
            expect(current_path).to eq(model_path(@address))
            expect(page).to have_selector('div.alert-notice')
          end
        end
      end
    end
  end

  def model_path(address)
    send("#{address.type.underscore}_path", address)
  end
end
