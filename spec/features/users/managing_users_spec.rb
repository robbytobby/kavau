require 'rails_helper'

RSpec.describe "Managing users"  do
  before(:each){ login_as create(:admin) }

  ['User', 'Buchhalter_in', 'Administrator_in'].each do |type|
    it "creating is possible" do
      visit users_path
      click_on :new_user
      expect(current_path).to eq(new_user_path)
      fill_in :user_login, with: 'LOGIN'
      select type, from: :user_role
      fill_in :user_password, with: '1Abcdefg'
      fill_in :user_password_confirmation, with: '1Abcdefg'
      fill_in :user_first_name, with: 'First Name'
      fill_in :user_name, with: 'Name'
      fill_in :user_email, with: 'name@test.org'
      click_on :submit
      expect(current_path).to eq(users_path)
      expect(page).to have_selector('div.alert-success')
    end
  end

  it "canceling create is possible" do
    visit users_path
    click_on :new_user
    click_on :cancel
    expect(current_path).to eq(users_path)
  end

  [:user, :accountant, :admin].each do |type|
    context "existing #{type}" do
      before(:each){@user = create type}

      it "is possible to edit" do
        visit users_path
        click_on "edit_user_#{@user.id}"
        fill_in :user_name, with: 'New Name'
        click_on :submit
        expect(current_path).to eq(users_path)
        expect(page).to have_selector('div.alert-success')
      end

      it "is possible to cancel editing" do
        visit users_path
        click_on "edit_user_#{@user.id}"
        click_on :cancel
        expect(current_path).to eq(users_path)
      end

      it "is possible to delete" do
        visit users_path
        click_on "delete_user_#{@user.id}"
        expect(current_path).to eq(users_path)
        expect(page).to have_selector('div.alert-success')
      end

    end
  end
end

