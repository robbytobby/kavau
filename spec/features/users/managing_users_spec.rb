require 'rails_helper'

RSpec.describe "Managing users (only possible for admins)"  do
  before(:each){ login_as create(:admin) }

  { user: 'User', accountant: 'Buchhalter_in', admin: 'Administrator_in' }.each_pair do |type, name|
    it "creating a #{type} is possible" do
      visit users_path
      click_on :new_user
      expect(current_path).to eq(new_user_path)
      fill_in :user_login, with: 'LOGIN'
      select name, from: :user_role
      fill_in :user_password, with: '1Abcdefg'
      fill_in :user_password_confirmation, with: '1Abcdefg'
      fill_in :user_first_name, with: 'First Name'
      fill_in :user_name, with: 'Name'
      fill_in :user_email, with: 'name@test.org'
      click_on :submit
      expect(current_path).to eq(users_path)
      expect(page).to have_selector('div.alert-notice')
    end
  end

  it "canceling creating a user is possible" do
    visit users_path
    click_on :new_user
    click_on :cancel
    expect(current_path).to eq(users_path)
  end

  [:user, :accountant, :admin].each do |type|
    context "existing #{type}" do
      before(:each){@user = create type}

      it "is editable" do
        visit users_path
        click_on "edit_user_#{@user.id}"
        fill_in :user_name, with: 'New Name'
        click_on :submit
        expect(current_path).to eq(users_path)
        expect(page).to have_selector('div.alert-notice')
      end

      it "canceling edit is possible" do
        visit users_path
        click_on "edit_user_#{@user.id}"
        click_on :cancel
        expect(current_path).to eq(users_path)
      end

      it "is deletable" do
        visit users_path
        click_on "delete_user_#{@user.id}"
        expect(current_path).to eq(users_path)
        expect(page).to have_selector('div.alert-notice')
      end
    end
  end
end

