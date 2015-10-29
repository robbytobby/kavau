require 'rails_helper'

[:user, :accountant, :admin].each do |type|
  RSpec.describe "manage own user data as #{type}"  do
    before(:each){ @user = create type }
    before(:each){ login_as @user }

    it "I can edit own account" do
      visit '/'
      click_on :edit_profile
      expect(current_path).to eq(edit_user_path(@user))
      expect(page).to_not have_css('select#user_role') if type != :admin
      fill_in :user_login, with: 'New Login'
      click_on :submit
      expect(current_path).to eq('/project')
      expect(page).to have_selector('div.alert-success')
    end

    it "I can cancel editing own account" do
      visit '/'
      click_on :edit_profile
      click_on :cancel
      expect(current_path).to eq('/project')
    end
  end
end
